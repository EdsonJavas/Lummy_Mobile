-- =====================================================
-- MIGRATION: Criar sistema de missões diárias
-- =====================================================
-- Cria tabelas para gerenciar 30 missões pré-definidas
-- e selecionar 5 aleatórias por dia

-- =====================================================
-- 1. TABELA: missions (Missões Pré-definidas)
-- =====================================================
-- Armazena as 30 missões disponíveis no sistema

CREATE TABLE IF NOT EXISTS missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  emoji TEXT NOT NULL,
  points INTEGER NOT NULL CHECK (points > 0),
  progress_target INTEGER NOT NULL DEFAULT 1 CHECK (progress_target > 0),
  color_hex TEXT NOT NULL, -- Cor em hex para o app
  category TEXT, -- Categoria da missão (opcional)
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_missions_is_active ON missions(is_active);
CREATE INDEX IF NOT EXISTS idx_missions_category ON missions(category);

-- =====================================================
-- 2. TABELA: daily_missions (Missões Diárias Selecionadas)
-- =====================================================
-- Armazena quais missões foram selecionadas para cada dia
-- e se foram concluídas

CREATE TABLE IF NOT EXISTS daily_missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  mission_id UUID NOT NULL REFERENCES missions(id) ON DELETE CASCADE,
  selected_date DATE NOT NULL, -- Data em que a missão foi selecionada
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMPTZ, -- Quando foi concluída
  progress INTEGER NOT NULL DEFAULT 0, -- Progresso atual (0 até progress_target)
  points_earned INTEGER DEFAULT 0, -- Pontos ganhos (0 se não concluída)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(child_id, mission_id, selected_date) -- Uma missão só pode ser selecionada uma vez por dia
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_daily_missions_child_id ON daily_missions(child_id);
CREATE INDEX IF NOT EXISTS idx_daily_missions_mission_id ON daily_missions(mission_id);
CREATE INDEX IF NOT EXISTS idx_daily_missions_selected_date ON daily_missions(selected_date);
CREATE INDEX IF NOT EXISTS idx_daily_missions_child_date ON daily_missions(child_id, selected_date);

-- =====================================================
-- 3. INSERIR 30 MISSÕES PRÉ-DEFINIDAS
-- =====================================================

INSERT INTO missions (title, description, emoji, points, progress_target, color_hex, category) VALUES
-- Categoria: Educação Financeira
('Aprendiz do Dinheiro', 'Leia 3 dicas de educação financeira', '📚', 10, 3, '3B82F6', 'educacao'),
('Economista Mirim', 'Adicione R$ 5,00 na sua meta de economia', '💰', 20, 5, '10B981', 'economia'),
('Planejador do Futuro', 'Crie ou atualize uma meta de economia', '🎯', 15, 1, '8B5CF6', 'planejamento'),
('Explorador Financeiro', 'Assista uma aula sobre dinheiro', '🎓', 25, 1, 'F59E0B', 'educacao'),
('Guardião da Mesada', 'Não gaste nada hoje', '🛡️', 30, 1, 'EF4444', 'economia'),

-- Categoria: Economia
('Poupança do Dia', 'Economize R$ 2,00 hoje', '💵', 15, 2, '10B981', 'economia'),
('Cofrinho Cheio', 'Adicione R$ 10,00 na sua meta', '🐷', 25, 10, '10B981', 'economia'),
('Economia Inteligente', 'Resista a comprar algo desnecessário', '🧠', 20, 1, '3B82F6', 'economia'),
('Super Economizador', 'Economize R$ 15,00 hoje', '💪', 35, 15, '10B981', 'economia'),
('Mestre da Poupança', 'Adicione R$ 20,00 na sua meta', '👑', 40, 20, '10B981', 'economia'),

-- Categoria: Metas
('Criador de Sonhos', 'Crie uma nova meta de economia', '✨', 20, 1, '8B5CF6', 'metas'),
('Conquistador de Metas', 'Complete 50% de uma meta', '🏆', 30, 1, '8B5CF6', 'metas'),
('Visionário', 'Defina uma meta para os próximos 30 dias', '🔮', 25, 1, '8B5CF6', 'metas'),
('Persistente', 'Mantenha uma meta ativa por 7 dias', '⏰', 35, 7, '8B5CF6', 'metas'),
('Realizador', 'Complete uma meta de economia', '🎉', 50, 1, '8B5CF6', 'metas'),

-- Categoria: Aprendizado
('Estudante Dedicado', 'Leia 5 dicas financeiras', '📖', 20, 5, 'F59E0B', 'educacao'),
('Curioso Financeiro', 'Assista 2 vídeos educativos', '👀', 25, 2, 'F59E0B', 'educacao'),
('Sábio do Dinheiro', 'Complete 3 lições sobre economia', '🧘', 30, 3, 'F59E0B', 'educacao'),
('Aprendiz Avançado', 'Leia 10 dicas financeiras', '📚', 40, 10, 'F59E0B', 'educacao'),
('Mestre Financeiro', 'Complete todas as lições do dia', '🎓', 50, 1, 'F59E0B', 'educacao'),

-- Categoria: Consistência
('Dia Perfeito', 'Complete todas as missões do dia', '⭐', 100, 5, 'FFD700', 'consistencia'),
('Semanário', 'Complete missões por 3 dias seguidos', '📅', 45, 3, 'FFD700', 'consistencia'),
('Mensal', 'Complete missões por 7 dias seguidos', '🗓️', 80, 7, 'FFD700', 'consistencia'),
('Veterano', 'Complete missões por 14 dias seguidos', '🎖️', 150, 14, 'FFD700', 'consistencia'),
('Lendário', 'Complete missões por 30 dias seguidos', '👑', 300, 30, 'FFD700', 'consistencia'),

-- Categoria: Controle
('Controle Total', 'Anote todos os gastos do dia', '📝', 20, 1, 'EF4444', 'controle'),
('Organizador', 'Revise suas metas de economia', '📊', 15, 1, 'EF4444', 'controle'),
('Fiscal', 'Verifique seu saldo atual', '🔍', 10, 1, 'EF4444', 'controle'),
('Analista', 'Compare seus gastos da semana', '📈', 25, 1, 'EF4444', 'controle'),
('Estrategista', 'Planeje seus gastos da semana', '🗺️', 30, 1, 'EF4444', 'controle'),

-- Categoria: Diversão
('Desafio da Economia', 'Economize mais do que ontem', '🎲', 25, 1, '8B5CF6', 'diversao'),
('Jogo da Poupança', 'Economize R$ 3,00 em moedas', '🪙', 20, 3, '8B5CF6', 'diversao'),
('Desafio Semanal', 'Economize R$ 50,00 esta semana', '📦', 60, 50, '8B5CF6', 'diversao')
ON CONFLICT DO NOTHING; -- Se já existirem, não inserir novamente

-- =====================================================
-- 4. FUNÇÃO: Selecionar 5 missões aleatórias para o dia
-- =====================================================

CREATE OR REPLACE FUNCTION select_daily_missions(
  p_child_id UUID,
  p_selected_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(mission_id UUID, title TEXT, description TEXT, emoji TEXT, points INTEGER, progress_target INTEGER, color_hex TEXT) AS $$
BEGIN
  -- Verificar se já existem missões selecionadas para hoje
  IF EXISTS (
    SELECT 1 FROM daily_missions 
    WHERE child_id = p_child_id 
    AND selected_date = p_selected_date
  ) THEN
    -- Retornar missões já selecionadas
    RETURN QUERY
    SELECT 
      m.id as mission_id,
      m.title,
      m.description,
      m.emoji,
      m.points,
      m.progress_target,
      m.color_hex
    FROM daily_missions dm
    INNER JOIN missions m ON m.id = dm.mission_id
    WHERE dm.child_id = p_child_id
    AND dm.selected_date = p_selected_date
    ORDER BY dm.created_at;
  ELSE
    -- Selecionar 5 missões aleatórias que ainda não foram selecionadas hoje
    -- (ou que nunca foram selecionadas para este usuário)
    INSERT INTO daily_missions (child_id, mission_id, selected_date, is_completed, progress)
    SELECT 
      p_child_id,
      m.id,
      p_selected_date,
      false,
      0
    FROM missions m
    WHERE m.is_active = true
    AND m.id NOT IN (
      -- Excluir missões que já foram selecionadas hoje
      SELECT dm2.mission_id FROM daily_missions dm2
      WHERE dm2.child_id = p_child_id 
      AND dm2.selected_date = p_selected_date
    )
    ORDER BY RANDOM()
    LIMIT 5;

    -- Retornar as missões selecionadas
    RETURN QUERY
    SELECT 
      m.id as mission_id,
      m.title,
      m.description,
      m.emoji,
      m.points,
      m.progress_target,
      m.color_hex
    FROM daily_missions dm
    INNER JOIN missions m ON m.id = dm.mission_id
    WHERE dm.child_id = p_child_id
    AND dm.selected_date = p_selected_date
    ORDER BY dm.created_at;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. FUNÇÃO: Completar missão e atualizar pontos
-- =====================================================

CREATE OR REPLACE FUNCTION complete_daily_mission(
  p_child_id UUID,
  p_mission_id UUID,
  p_selected_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
  points_earned INTEGER,
  new_total_points INTEGER,
  new_level INTEGER
) AS $$
DECLARE
  v_points INTEGER;
  v_current_points INTEGER;
  v_new_points INTEGER;
  v_new_level INTEGER;
BEGIN
  -- Buscar pontos da missão
  SELECT m.points INTO v_points
  FROM missions m
  WHERE m.id = p_mission_id;

  IF v_points IS NULL THEN
    RAISE EXCEPTION 'Missão não encontrada';
  END IF;

  -- Marcar missão como concluída
  UPDATE daily_missions
  SET 
    is_completed = true,
    completed_at = NOW(),
    progress = (SELECT m2.progress_target FROM missions m2 WHERE m2.id = p_mission_id),
    points_earned = v_points,
    updated_at = NOW()
  WHERE child_id = p_child_id
  AND mission_id = p_mission_id
  AND selected_date = p_selected_date
  AND is_completed = false;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Missão não encontrada ou já concluída';
  END IF;

  -- Buscar pontos atuais do usuário
  SELECT total_points INTO v_current_points
  FROM children
  WHERE id = p_child_id;

  -- Calcular novos pontos e nível
  v_new_points := COALESCE(v_current_points, 0) + v_points;
  v_new_level := (v_new_points / 1000) + 1; -- Nível sobe a cada 1000 pontos

  -- Atualizar pontos e nível na tabela children
  UPDATE children
  SET 
    total_points = v_new_points,
    level = v_new_level,
    updated_at = NOW()
  WHERE id = p_child_id;

  -- Retornar resultados
  RETURN QUERY
  SELECT 
    v_points as points_earned,
    v_new_points as new_total_points,
    v_new_level as new_level;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. TRIGGER: Atualizar updated_at automaticamente
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_missions_updated_at
  BEFORE UPDATE ON missions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_daily_missions_updated_at
  BEFORE UPDATE ON daily_missions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FIM DA MIGRATION
-- =====================================================

