-- Notificações remotas do Lummy (Firebase Cloud Messaging).
--
-- 1. push_tokens: aparelhos de cada usuário (gravados pelo app nas RPCs abaixo).
-- 2. push_notifications: fila de avisos. Cada linha nova chama a Edge Function
--    `send-push` (via pg_net), que envia pelo FCM e marca `sent_at`.
-- 3. Gatilhos nos eventos do app criam as linhas da fila.
--
-- Regra de segurança: um gatilho de aviso NUNCA pode impedir a gravação
-- original. Todo gatilho daqui engole o próprio erro (raise warning).
--
-- Depois de aplicar esta migration:
--   a) publicar a Edge Function supabase/functions/send-push com
--      "Enforce JWT verification" DESLIGADO (o banco chama sem JWT; a função
--      só envia avisos que já estão na fila);
--   b) criar o segredo FIREBASE_SERVICE_ACCOUNT com o JSON da conta de serviço
--      do projeto Firebase lummy-dce58.

create extension if not exists pg_net;

-- ─── 1. Aparelhos ────────────────────────────────────────────────────────────

create table if not exists public.push_tokens (
  token text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null check (platform in ('ios', 'android')),
  updated_at timestamptz not null default now()
);

create index if not exists idx_push_tokens_user on public.push_tokens(user_id);

alter table public.push_tokens enable row level security;

drop policy if exists "push_tokens: dono le" on public.push_tokens;
create policy "push_tokens: dono le" on public.push_tokens
  for select using (auth.uid() = user_id);

-- Grava o aparelho para o usuário logado. O mesmo aparelho pode trocar de
-- conta (pai e filho no mesmo celular): o token passa para quem entrou.
create or replace function public.register_push_token(p_token text, p_platform text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'sem sessão';
  end if;
  insert into public.push_tokens (token, user_id, platform, updated_at)
  values (p_token, auth.uid(), p_platform, now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        updated_at = now();
end;
$$;

-- Apaga o aparelho depois do logout (já sem sessão: quem tem o token é o
-- próprio aparelho).
create or replace function public.unregister_push_token(p_token text)
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.push_tokens where token = p_token;
$$;

revoke all on function public.register_push_token(text, text) from public;
revoke all on function public.unregister_push_token(text) from public;
grant execute on function public.register_push_token(text, text) to authenticated;
grant execute on function public.unregister_push_token(text) to anon, authenticated;

-- ─── 2. Fila de avisos ───────────────────────────────────────────────────────

create table if not exists public.push_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  read_at timestamptz
);

create index if not exists idx_push_notifications_user
  on public.push_notifications(user_id, created_at desc);

alter table public.push_notifications enable row level security;

drop policy if exists "push_notifications: dono le" on public.push_notifications;
create policy "push_notifications: dono le" on public.push_notifications
  for select using (auth.uid() = user_id);

drop policy if exists "push_notifications: dono marca lida" on public.push_notifications;
create policy "push_notifications: dono marca lida" on public.push_notifications
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Só os gatilhos (security definer) inserem na fila.

create or replace function public.lummy_enfileirar_aviso(
  p_user_id uuid,
  p_title text,
  p_body text,
  p_data jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_user_id is null then
    return;
  end if;
  insert into public.push_notifications (user_id, title, body, data)
  values (p_user_id, p_title, p_body, coalesce(p_data, '{}'::jsonb));
exception when others then
  raise warning 'lummy_enfileirar_aviso: %', sqlerrm;
end;
$$;

revoke all on function public.lummy_enfileirar_aviso(uuid, text, text, jsonb) from public;

-- "R$ 12,50"
create or replace function public.lummy_reais(p_valor numeric)
returns text
language sql
immutable
as $$
  select 'R$ ' || replace(to_char(coalesce(p_valor, 0), 'FM9999999990.00'), '.', ',');
$$;

-- Cada aviso novo chama a Edge Function que envia pelo FCM.
create or replace function public.lummy_disparar_aviso()
returns trigger
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  perform net.http_post(
    url := 'https://rcskqcorfmmeignsgcuj.supabase.co/functions/v1/send-push',
    body := jsonb_build_object('id', new.id),
    headers := '{"Content-Type": "application/json"}'::jsonb,
    timeout_milliseconds := 5000
  );
  return new;
exception when others then
  raise warning 'lummy_disparar_aviso: %', sqlerrm;
  return new;
end;
$$;

drop trigger if exists trg_push_notifications_disparar on public.push_notifications;
create trigger trg_push_notifications_disparar
  after insert on public.push_notifications
  for each row execute function public.lummy_disparar_aviso();

-- ─── 3. Eventos do app ───────────────────────────────────────────────────────

-- Transações:
--  - gasto novo pendente → responsável ("aprove ou recuse");
--  - dinheiro enviado pelo responsável → criança;
--  - gasto aprovado/recusado → criança.
create or replace function public.lummy_aviso_transacao()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_nome text;
  v_responsavel uuid;
  v_descricao text;
begin
  select c.nome, c.responsavel_id
    into v_nome, v_responsavel
    from public.children c
   where c.id = new.child_id;
  v_nome := coalesce(nullif(split_part(trim(v_nome), ' ', 1), ''), 'Seu filho');
  v_descricao := coalesce(nullif(trim(new.description), ''), new.category, 'gasto');

  if tg_op = 'INSERT' then
    if new.type = 'expense' and new.status = 'pending' then
      perform public.lummy_enfileirar_aviso(
        v_responsavel,
        'Novo gasto de ' || v_nome,
        v_nome || ' anotou ' || public.lummy_reais(new.amount) || ' em ' || v_descricao || '. Aprove ou recuse no app.',
        jsonb_build_object('tipo', 'gasto_pendente', 'transaction_id', new.id, 'child_id', new.child_id)
      );
    elsif new.type = 'income' and new.parent_id is not null then
      perform public.lummy_enfileirar_aviso(
        new.child_id,
        'Você recebeu ' || public.lummy_reais(new.amount) || '!',
        'Seus pais mandaram dinheiro para o seu cofrinho.',
        jsonb_build_object('tipo', 'dinheiro_recebido', 'transaction_id', new.id)
      );
    end if;
  elsif tg_op = 'UPDATE'
        and new.type = 'expense'
        and old.status = 'pending'
        and new.status in ('approved', 'rejected') then
    perform public.lummy_enfileirar_aviso(
      new.child_id,
      case when new.status = 'approved' then 'Gasto aprovado' else 'Gasto recusado' end,
      case
        when new.status = 'approved'
          then 'Seus pais aprovaram o gasto de ' || public.lummy_reais(new.amount) || ' em ' || v_descricao || '.'
        else 'Seus pais recusaram o gasto de ' || public.lummy_reais(new.amount) || ' em ' || v_descricao || '. Abra o app para ver o motivo.'
      end,
      jsonb_build_object('tipo', 'gasto_' || new.status, 'transaction_id', new.id)
    );
  end if;
  return new;
exception when others then
  raise warning 'lummy_aviso_transacao: %', sqlerrm;
  return new;
end;
$$;

drop trigger if exists trg_transactions_aviso on public.transactions;
create trigger trg_transactions_aviso
  after insert or update of status on public.transactions
  for each row execute function public.lummy_aviso_transacao();

-- Mesada separada para resgate → cada filho do responsável.
create or replace function public.lummy_aviso_distribuicao()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_filho record;
begin
  if new.status = 'active' then
    for v_filho in
      select c.id from public.children c where c.responsavel_id = new.parent_id
    loop
      perform public.lummy_enfileirar_aviso(
        v_filho.id,
        'Tem mesada para você',
        'Seus pais separaram ' || public.lummy_reais(new.total_amount) || ' para dividir. Abra o Lummy e retire sua parte.',
        jsonb_build_object('tipo', 'mesada_disponivel', 'distribution_id', new.id)
      );
    end loop;
  end if;
  return new;
exception when others then
  raise warning 'lummy_aviso_distribuicao: %', sqlerrm;
  return new;
end;
$$;

drop trigger if exists trg_allowance_distributions_aviso on public.allowance_distributions;
create trigger trg_allowance_distributions_aviso
  after insert on public.allowance_distributions
  for each row execute function public.lummy_aviso_distribuicao();

-- Missão nova criada pelo responsável → criança.
create or replace function public.lummy_aviso_missao()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.lummy_enfileirar_aviso(
    new.child_id,
    'Missão nova!',
    coalesce(nullif(trim(new.title), ''), 'Seus pais criaram uma missão para você') || '. Vale XP!',
    jsonb_build_object('tipo', 'missao_nova', 'mission_id', new.id)
  );
  return new;
exception when others then
  raise warning 'lummy_aviso_missao: %', sqlerrm;
  return new;
end;
$$;

drop trigger if exists trg_custom_missions_aviso on public.custom_missions;
create trigger trg_custom_missions_aviso
  after insert on public.custom_missions
  for each row execute function public.lummy_aviso_missao();

-- Meta conquistada → responsável.
create or replace function public.lummy_aviso_meta()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_nome text;
  v_responsavel uuid;
begin
  if new.status = 'completed' and old.status is distinct from 'completed' then
    select c.nome, c.responsavel_id
      into v_nome, v_responsavel
      from public.children c
     where c.id = new.child_id;
    v_nome := coalesce(nullif(split_part(trim(v_nome), ' ', 1), ''), 'Seu filho');
    perform public.lummy_enfileirar_aviso(
      v_responsavel,
      v_nome || ' conquistou uma meta!',
      v_nome || ' juntou ' || public.lummy_reais(new.target_amount) || ' e chegou na meta "' || coalesce(new.name, 'meta') || '".',
      jsonb_build_object('tipo', 'meta_conquistada', 'goal_id', new.id, 'child_id', new.child_id)
    );
  end if;
  return new;
exception when others then
  raise warning 'lummy_aviso_meta: %', sqlerrm;
  return new;
end;
$$;

drop trigger if exists trg_goals_aviso on public.goals;
create trigger trg_goals_aviso
  after update of status on public.goals
  for each row execute function public.lummy_aviso_meta();
