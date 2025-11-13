-- =====================================================
-- MIGRATION: Criar sistema de metas (goals)
-- =====================================================
-- Cria tabela para armazenar metas dos usuários
-- Apenas uma meta pode estar ativa (em andamento) por vez

-- =====================================================
-- TABELA: goals (Metas)
-- =====================================================

CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '🎯',
  description TEXT DEFAULT '',
  target_amount DECIMAL(10, 2) NOT NULL CHECK (target_amount > 0),
  current_amount DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (current_amount >= 0),
  status TEXT NOT NULL DEFAULT 'ongoing' CHECK (status IN ('ongoing', 'completed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT check_current_not_exceed_target CHECK (current_amount <= target_amount)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_goals_child_id ON goals(child_id);
CREATE INDEX IF NOT EXISTS idx_goals_status ON goals(status);
CREATE INDEX IF NOT EXISTS idx_goals_child_status ON goals(child_id, status);
CREATE INDEX IF NOT EXISTS idx_goals_completed_at ON goals(completed_at);

-- Constraint: Garantir que apenas uma meta "ongoing" por usuário
-- Isso será feito através de trigger ou validação no código da aplicação
-- Mas podemos criar um índice único parcial para ajudar
CREATE UNIQUE INDEX IF NOT EXISTS idx_goals_one_ongoing_per_child 
ON goals(child_id) 
WHERE status = 'ongoing';

-- Comentários
COMMENT ON TABLE goals IS 'Metas de economia dos usuários';
COMMENT ON COLUMN goals.child_id IS 'ID do usuário (child) que possui a meta';
COMMENT ON COLUMN goals.name IS 'Nome da meta';
COMMENT ON COLUMN goals.emoji IS 'Emoji representativo da meta';
COMMENT ON COLUMN goals.description IS 'Descrição opcional da meta';
COMMENT ON COLUMN goals.target_amount IS 'Valor total que se deseja economizar';
COMMENT ON COLUMN goals.current_amount IS 'Valor já economizado até o momento';
COMMENT ON COLUMN goals.status IS 'Status da meta: ongoing (em andamento) ou completed (concluída)';
COMMENT ON COLUMN goals.completed_at IS 'Data/hora em que a meta foi concluída';

-- =====================================================
-- TRIGGER: Atualizar updated_at automaticamente
-- =====================================================

CREATE OR REPLACE FUNCTION update_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_goals_updated_at
  BEFORE UPDATE ON goals
  FOR EACH ROW
  EXECUTE FUNCTION update_goals_updated_at();

-- =====================================================
-- FUNÇÃO: Verificar e completar meta automaticamente
-- =====================================================

CREATE OR REPLACE FUNCTION check_and_complete_goal()
RETURNS TRIGGER AS $$
BEGIN
  -- Se current_amount >= target_amount e status ainda é 'ongoing', completar
  IF NEW.current_amount >= NEW.target_amount AND NEW.status = 'ongoing' THEN
    NEW.status := 'completed';
    NEW.completed_at := NOW();
    NEW.current_amount := NEW.target_amount; -- Garantir que não exceda
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_goal_completion
  BEFORE INSERT OR UPDATE ON goals
  FOR EACH ROW
  EXECUTE FUNCTION check_and_complete_goal();

-- =====================================================
-- FIM DA MIGRATION
-- =====================================================

