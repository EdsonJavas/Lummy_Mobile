-- =====================================================
-- LUMMY - SCHEMA DO BANCO DE DADOS SUPABASE
-- =====================================================
-- Este arquivo contém o schema completo do banco de dados
-- para o aplicativo Lummy de educação financeira para crianças
-- =====================================================

-- =====================================================
-- 1. EXTENSÕES NECESSÁRIAS
-- =====================================================
-- Habilitar extensão UUID se necessário
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 2. TABELA: responsaveis (Pais/Responsáveis)
-- =====================================================
-- Armazena dados adicionais dos responsáveis
-- O ID é o mesmo do Supabase Auth (auth.users.id)

CREATE TABLE IF NOT EXISTS responsaveis (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  cpf TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índice para busca rápida por CPF e email
CREATE INDEX IF NOT EXISTS idx_responsaveis_cpf ON responsaveis(cpf);
CREATE INDEX IF NOT EXISTS idx_responsaveis_email ON responsaveis(email);

-- =====================================================
-- 3. TABELA: children (Crianças)
-- =====================================================
-- Armazena dados das crianças
-- O ID é o mesmo do Supabase Auth (auth.users.id)

CREATE TABLE IF NOT EXISTS children (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  responsavel_id UUID NOT NULL REFERENCES responsaveis(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  cpf TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  idade INTEGER NOT NULL CHECK (idade >= 1 AND idade <= 17),
  sexo TEXT NOT NULL CHECK (sexo IN ('Masculino', 'Feminino', 'Outro')),
  balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  allowance DECIMAL(10, 2) NOT NULL DEFAULT 0.00, -- Mesada
  requires_approval BOOLEAN NOT NULL DEFAULT true, -- Se transações precisam aprovação
  total_points INTEGER NOT NULL DEFAULT 0, -- Pontos totais acumulados
  level INTEGER NOT NULL DEFAULT 1, -- Nível atual do usuário
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para busca rápida
CREATE INDEX IF NOT EXISTS idx_children_responsavel_id ON children(responsavel_id);
CREATE INDEX IF NOT EXISTS idx_children_cpf ON children(cpf);
CREATE INDEX IF NOT EXISTS idx_children_email ON children(email);
CREATE INDEX IF NOT EXISTS idx_children_total_points ON children(total_points);
CREATE INDEX IF NOT EXISTS idx_children_level ON children(level);

-- =====================================================
-- 4. TABELA: transactions (Transações Financeiras)
-- =====================================================
-- Armazena todas as transações financeiras das crianças
-- Tipos: income (entrada), expense (gasto), allowance (mesada), reward (recompensa)
-- Status: pending, approved, rejected, completed

CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES responsaveis(id) ON DELETE SET NULL,
  description TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'allowance', 'reward')),
  status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected', 'completed')) DEFAULT 'pending',
  category TEXT NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  rejection_reason TEXT,
  metadata JSONB, -- Dados extras (ex: foto do comprovante, localização, etc)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para consultas frequentes
CREATE INDEX IF NOT EXISTS idx_transactions_child_id ON transactions(child_id);
CREATE INDEX IF NOT EXISTS idx_transactions_parent_id ON transactions(parent_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);

-- =====================================================
-- 5. TABELA: goals (Metas de Economia)
-- =====================================================
-- Armazena as metas de economia das crianças

CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES responsaveis(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  emoji TEXT NOT NULL,
  target_amount DECIMAL(10, 2) NOT NULL CHECK (target_amount > 0),
  current_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (current_amount >= 0),
  status TEXT NOT NULL CHECK (status IN ('active', 'completed', 'cancelled')) DEFAULT 'active',
  deadline DATE,
  description TEXT DEFAULT '',
  is_shared BOOLEAN NOT NULL DEFAULT false, -- Se é compartilhada com o responsável
  milestones JSONB, -- Marcos intermediários ["25%", "50%", "75%"]
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_goals_child_id ON goals(child_id);
CREATE INDEX IF NOT EXISTS idx_goals_parent_id ON goals(parent_id);
CREATE INDEX IF NOT EXISTS idx_goals_status ON goals(status);
CREATE INDEX IF NOT EXISTS idx_goals_deadline ON goals(deadline) WHERE deadline IS NOT NULL;

-- =====================================================
-- 6. TABELA: achievements (Conquistas)
-- =====================================================
-- Armazena as conquistas/conquistas das crianças

CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  emoji TEXT NOT NULL,
  is_completed BOOLEAN NOT NULL DEFAULT false,
  completed_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_achievements_child_id ON achievements(child_id);
CREATE INDEX IF NOT EXISTS idx_achievements_completed ON achievements(is_completed);

-- =====================================================
-- 7. FUNÇÕES E TRIGGERS
-- =====================================================

-- Função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER update_responsaveis_updated_at
  BEFORE UPDATE ON responsaveis
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_children_updated_at
  BEFORE UPDATE ON children
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at
  BEFORE UPDATE ON transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at
  BEFORE UPDATE ON goals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_achievements_updated_at
  BEFORE UPDATE ON achievements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Função para atualizar balance da criança quando transação é aprovada
CREATE OR REPLACE FUNCTION update_child_balance()
RETURNS TRIGGER AS $$
BEGIN
  -- Só atualiza quando status muda para 'approved' ou 'completed'
  IF (NEW.status = 'approved' OR NEW.status = 'completed') AND 
     (OLD.status != 'approved' AND OLD.status != 'completed') THEN
    
    IF NEW.type = 'income' OR NEW.type = 'allowance' OR NEW.type = 'reward' THEN
      UPDATE children 
      SET balance = balance + NEW.amount
      WHERE id = NEW.child_id;
    
    ELSIF NEW.type = 'expense' THEN
      UPDATE children 
      SET balance = balance - NEW.amount
      WHERE id = NEW.child_id;
    END IF;
  
  -- Reverte o balance se a transação foi rejeitada ou cancelada
  ELSIF (NEW.status = 'rejected' OR NEW.status = 'pending') AND
        (OLD.status = 'approved' OR OLD.status = 'completed') THEN
    
    IF OLD.type = 'income' OR OLD.type = 'allowance' OR OLD.type = 'reward' THEN
      UPDATE children 
      SET balance = balance - OLD.amount
      WHERE id = NEW.child_id;
    
    ELSIF OLD.type = 'expense' THEN
      UPDATE children 
      SET balance = balance + OLD.amount
      WHERE id = NEW.child_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar balance automaticamente
CREATE TRIGGER trigger_update_child_balance
  AFTER INSERT OR UPDATE OF status ON transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_child_balance();

-- Função para atualizar current_amount da meta quando balance muda
CREATE OR REPLACE FUNCTION sync_goal_amount()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualiza a meta ativa mais recente com o novo balance
  UPDATE goals
  SET current_amount = NEW.balance
  WHERE child_id = NEW.id 
    AND status = 'active'
    AND id = (
      SELECT id FROM goals 
      WHERE child_id = NEW.id AND status = 'active'
      ORDER BY created_at DESC
      LIMIT 1
    );
  
  -- Marca meta como completed se atingiu o target
  UPDATE goals
  SET status = 'completed',
      completed_at = NOW()
  WHERE child_id = NEW.id
    AND status = 'active'
    AND current_amount >= target_amount;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para sincronizar meta com balance
CREATE TRIGGER trigger_sync_goal_amount
  AFTER UPDATE OF balance ON children
  FOR EACH ROW
  WHEN (OLD.balance IS DISTINCT FROM NEW.balance)
  EXECUTE FUNCTION sync_goal_amount();

-- =====================================================
-- 8. VIEWS ÚTEIS
-- =====================================================

-- View para resumo financeiro das crianças
CREATE OR REPLACE VIEW child_financial_summary AS
SELECT 
  c.id as child_id,
  c.nome,
  c.balance,
  c.allowance,
  COUNT(DISTINCT t.id) as total_transactions,
  COUNT(DISTINCT CASE WHEN t.type = 'expense' THEN t.id END) as total_expenses,
  COUNT(DISTINCT CASE WHEN t.type IN ('income', 'allowance', 'reward') THEN t.id END) as total_incomes,
  COALESCE(SUM(CASE WHEN t.type = 'expense' AND t.status IN ('approved', 'completed') THEN t.amount ELSE 0 END), 0) as total_expense_amount,
  COALESCE(SUM(CASE WHEN t.type IN ('income', 'allowance', 'reward') AND t.status IN ('approved', 'completed') THEN t.amount ELSE 0 END), 0) as total_income_amount,
  COUNT(DISTINCT g.id) FILTER (WHERE g.status = 'active') as active_goals,
  COUNT(DISTINCT a.id) FILTER (WHERE a.is_completed = true) as completed_achievements
FROM children c
LEFT JOIN transactions t ON t.child_id = c.id
LEFT JOIN goals g ON g.child_id = c.id
LEFT JOIN achievements a ON a.child_id = c.id
GROUP BY c.id, c.nome, c.balance, c.allowance;

-- =====================================================
-- 9. COMENTÁRIOS DAS TABELAS
-- =====================================================

COMMENT ON TABLE responsaveis IS 'Dados dos pais/responsáveis. ID vinculado ao auth.users';
COMMENT ON TABLE children IS 'Dados das crianças. ID vinculado ao auth.users';
COMMENT ON TABLE transactions IS 'Transações financeiras das crianças (receitas, despesas, mesadas, recompensas)';
COMMENT ON TABLE goals IS 'Metas de economia das crianças';
COMMENT ON TABLE achievements IS 'Conquistas e badges das crianças';
COMMENT ON TABLE missions IS 'Missões pré-definidas do sistema (30 missões disponíveis)';
COMMENT ON TABLE daily_missions IS 'Missões selecionadas para cada dia do usuário';

COMMENT ON COLUMN transactions.type IS 'Tipos: income (entrada), expense (gasto), allowance (mesada), reward (recompensa)';
COMMENT ON COLUMN transactions.status IS 'Status: pending (pendente), approved (aprovada), rejected (rejeitada), completed (concluída)';
COMMENT ON COLUMN goals.status IS 'Status: active (ativa), completed (concluída), cancelled (cancelada)';
COMMENT ON COLUMN children.requires_approval IS 'Se true, transações da criança precisam de aprovação do responsável';

-- =====================================================
-- 6. TABELA: missions (Missões Pré-definidas)
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
-- 7. TABELA: daily_missions (Missões Diárias Selecionadas)
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

-- Trigger para atualizar updated_at
CREATE TRIGGER update_missions_updated_at
  BEFORE UPDATE ON missions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_missions_updated_at
  BEFORE UPDATE ON daily_missions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FIM DO SCHEMA
-- =====================================================
-- NOTA: Para inserir as 30 missões pré-definidas e criar as funções,
-- execute o arquivo migration_create_missions.sql
