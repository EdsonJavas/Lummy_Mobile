-- =====================================================
-- MIGRATION: Adicionar campos de estatísticas do usuário
-- =====================================================
-- Adiciona campos para armazenar pontos totais e nível do usuário
-- na tabela children

-- Adicionar colunas se não existirem
DO $$ 
BEGIN
  -- Adicionar coluna total_points se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'children' AND column_name = 'total_points'
  ) THEN
    ALTER TABLE children ADD COLUMN total_points INTEGER NOT NULL DEFAULT 0;
    COMMENT ON COLUMN children.total_points IS 'Pontos totais acumulados pelo usuário';
  END IF;

  -- Adicionar coluna level se não existir
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'children' AND column_name = 'level'
  ) THEN
    ALTER TABLE children ADD COLUMN level INTEGER NOT NULL DEFAULT 1;
    COMMENT ON COLUMN children.level IS 'Nível atual do usuário (baseado em pontos)';
  END IF;
END $$;

-- Criar índice para busca rápida
CREATE INDEX IF NOT EXISTS idx_children_total_points ON children(total_points);
CREATE INDEX IF NOT EXISTS idx_children_level ON children(level);

-- =====================================================
-- FIM DA MIGRATION
-- =====================================================

