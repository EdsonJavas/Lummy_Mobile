-- =====================================================
-- CORREÇÃO: Remover ambiguidade nas funções de missões
-- =====================================================
-- Execute este script no SQL Editor do Supabase para corrigir
-- o erro de ambiguidade na coluna "mission_id"

-- =====================================================
-- 1. FUNÇÃO: Selecionar 5 missões aleatórias para o dia
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
-- 2. FUNÇÃO: Completar missão e atualizar pontos
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
-- FIM DA CORREÇÃO
-- =====================================================
-- As funções foram atualizadas para remover ambiguidade
-- na referência da coluna "mission_id"
