# Documentação do Aplicativo Lummy

## Visão Geral
- Aplicativo Flutter multiplataforma voltado à educação financeira de crianças e responsáveis.
- Integração com Supabase para autenticação, gerenciamento relacional de dados e políticas de segurança em nível de linha.
- Módulos principais: gestão de contas, movimentações financeiras, metas de economia, conquistas e missões diárias.

## Preparação do Projeto
- Requisitos: Flutter 3.22+, Dart 3.4+, projeto Supabase com Auth configurado.
- Instale as dependências: `flutter pub get`.
- Execute em dispositivo ou emulador: `flutter run`.
- As variáveis de ambiente ficam em `lib/core/config/supabase_config.dart`; confirme URL do projeto e chave anon antes de iniciar.

## Estrutura do Repositório
- `lib/` concentra o código Flutter nas camadas de aplicação, domínio, dados e recursos.
- `database/` centraliza os artefatos SQL:
  - `database/schema/supabase_schema.sql` – schema completo para novos ambientes.
  - `database/migrations/` – migrações incrementais para bancos existentes.
  - `database/patches/` – scripts corretivos para dados de produção.
- Código específico de plataforma está em `android/`, `ios/`, `macos/`, `windows/`, `linux/` e `web/`.

## Resumo do Schema de Banco
- `responsaveis`: responsáveis vinculados a `auth.users`.
- `children`: perfis de crianças com saldo, mesada, regras de aprovação, pontos totais e nível.
- `transactions`: histórico financeiro por criança, incluindo status de aprovação, categorias e metadados.
- `goals`: metas de economia com marcos, prazos, status e acompanhamento de conclusão.
- `achievements`: conquistas atribuídas às crianças.
- Políticas de segurança em nível de linha garantem que responsáveis manipulem apenas seus dependentes e crianças acessem apenas seus próprios registros.
- Principais triggers e funções:
  - `update_updated_at_column` mantém `updated_at` atualizado.
  - `update_child_balance` sincroniza o saldo quando o status das transações muda.
  - `sync_goal_amount` mantém a meta ativa alinhada ao saldo.

## Aplicação do Schema do Zero
1. No Supabase SQL Editor, execute `database/schema/supabase_schema.sql`.
2. Como alternativa, utilizando Supabase CLI no repositório:
   ```
   supabase db reset
   supabase db push
   ```
3. Confirme a criação com:
   ```
   SELECT table_name
   FROM information_schema.tables
   WHERE table_schema = 'public'
     AND table_name IN ('responsaveis', 'children', 'transactions', 'goals', 'achievements');
   ```

## Migrações Incrementais
- `database/migrations/migration_create_goals.sql`: cria `goals` e respectivos índices e padrões.
- `database/migrations/migration_create_missions.sql`: disponibiliza `missions`, `daily_missions`, dados iniciais e funções auxiliares.
- `database/migrations/migration_add_user_stats.sql`: adiciona `total_points` e `level` em `children` e ajusta as views relacionadas.

### Como Executar uma Migração
1. Abra o Supabase SQL Editor.
2. Crie uma nova query, cole o conteúdo da migração e execute.
3. Valide as alterações, por exemplo:
   ```
   SELECT column_name, data_type
   FROM information_schema.columns
   WHERE table_name = 'children'
     AND column_name IN ('total_points', 'level');
   ```

## Módulo de Missões Diárias
- Armazena 30 missões predefinidas em `missions`.
- Seleciona cinco missões únicas por criança a cada dia e registra em `daily_missions`.
- `select_daily_missions` retorna o conjunto do dia; na ausência, realiza nova seleção.
- `complete_daily_mission` finaliza a missão, credita pontos e recalcula o nível como `(total_points / 1000) + 1`.
- Consultas de verificação:
  ```
  SELECT COUNT(*) FROM missions;
  SELECT * FROM daily_missions WHERE selected_date = CURRENT_DATE;
  ```

## Estatísticas de Usuário na Tela de Perfil
- Carrega `total_points` e `level` de `children`, conquistas de `achievements` e contagem de metas concluídas de `goals`.
- A interface trata colunas ausentes com valores padrão; após `migration_add_user_stats.sql`, os dados permanecem persistentes.
- Após a migração:
  ```
  SELECT id, nome, total_points, level, balance
  FROM children
  WHERE id = 'UUID_DO_USUARIO';
  ```

## Diagnóstico e Manutenção do Banco
- Verificação de conexão: garanta que `lib/core/config/supabase_config.dart` possua credenciais alinhadas ao projeto Supabase.
- Validação de tabelas:
  ```
  SELECT table_name
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name IN ('responsaveis', 'children');
  ```
- Visibilidade das políticas de segurança:
  ```
  SELECT *
  FROM pg_policies
  WHERE tablename IN ('responsaveis', 'children');
  ```
- Políticas permissivas temporárias (somente em desenvolvimento):
  ```
  CREATE POLICY "dev_insert_responsaveis"
    ON responsaveis FOR INSERT TO authenticated WITH CHECK (true);
  CREATE POLICY "dev_select_responsaveis"
    ON responsaveis FOR SELECT TO authenticated USING (true);
  CREATE POLICY "dev_insert_children"
    ON children FOR INSERT TO authenticated WITH CHECK (true);
  CREATE POLICY "dev_select_children"
    ON children FOR SELECT TO authenticated USING (true);
  ```
- Consultas de diagnóstico:
  ```
  SELECT COUNT(*) FROM children;
  SELECT *
  FROM responsaveis
  ORDER BY created_at DESC
  LIMIT 5;
  ```
- Scripts em `database/patches/` corrigem restrições e lógica de missões em produção; avalie antes de executar.

## Verificação do Aplicativo
- Execute o app em modo debug e monitore o console para interações com o Supabase:
  - Mensagens de sucesso confirmam inserções concluídas.
  - Erros `permission denied` ou `relation does not exist` indicam políticas ou migrações pendentes.
- Passos de validação manual:
  1. Autentique-se como responsável e como criança.
  2. Confirme seleção e conclusão de missões em dias consecutivos.
  3. Crie transações que exijam aprovação e verifique o ajuste de saldo.
  4. Conclua metas para validar transições de status e desbloqueio de conquistas.

## Suporte Operacional
- Mantenha Flutter e Supabase CLI atualizados.
- Revise os scripts em `database/` antes de cada implantação em produção.
- Registre novas migrações ou patches no `README.md` para preservar esta referência única.