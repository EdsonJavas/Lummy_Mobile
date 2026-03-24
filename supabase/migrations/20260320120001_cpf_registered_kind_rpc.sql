-- Verifica se o CPF (apenas dígitos) já está em uso como responsável ou dependente.
-- Comparação ignora formatação nas colunas (remove não-dígitos).

CREATE OR REPLACE FUNCTION public.cpf_registered_kind(check_cpf text)
RETURNS text
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  d text;
BEGIN
  d := regexp_replace(trim(both FROM check_cpf), '[^0-9]', '', 'g');
  IF length(d) <> 11 THEN
    RETURN 'none';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM public.responsaveis r
    WHERE regexp_replace(trim(both FROM r.cpf::text), '[^0-9]', '', 'g') = d
  ) THEN
    RETURN 'parent';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM public.children c
    WHERE regexp_replace(trim(both FROM c.cpf::text), '[^0-9]', '', 'g') = d
  ) THEN
    RETURN 'child';
  END IF;
  RETURN 'none';
END;
$$;

REVOKE ALL ON FUNCTION public.cpf_registered_kind(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cpf_registered_kind(text) TO anon;
GRANT EXECUTE ON FUNCTION public.cpf_registered_kind(text) TO authenticated;

COMMENT ON FUNCTION public.cpf_registered_kind(text) IS
  'Retorna parent | child | none — evita reutilizar o mesmo CPF entre responsável e dependente.';
