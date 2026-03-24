-- Verifica se o e-mail já está em uso como responsável ou como dependente (tabelas públicas).
-- SECURITY DEFINER permite que anon/authenticated consultem antes do cadastro completo.
-- Aplique no projeto Supabase (CLI push ou SQL Editor).

CREATE OR REPLACE FUNCTION public.email_registered_kind(check_email text)
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT CASE
    WHEN EXISTS (
      SELECT 1
      FROM public.responsaveis r
      WHERE lower(trim(both FROM r.email::text)) = lower(trim(both FROM check_email))
    ) THEN 'parent'
    WHEN EXISTS (
      SELECT 1
      FROM public.children c
      WHERE lower(trim(both FROM c.email::text)) = lower(trim(both FROM check_email))
    ) THEN 'child'
    ELSE 'none'
  END;
$$;

REVOKE ALL ON FUNCTION public.email_registered_kind(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.email_registered_kind(text) TO anon;
GRANT EXECUTE ON FUNCTION public.email_registered_kind(text) TO authenticated;

COMMENT ON FUNCTION public.email_registered_kind(text) IS
  'Retorna parent | child | none — evita reutilizar o mesmo e-mail entre responsável e dependente.';
