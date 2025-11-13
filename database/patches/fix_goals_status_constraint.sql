-- =====================================================
-- CORREÇÃO: Corrigir constraint de status na tabela goals
-- =====================================================
-- Execute este script se estiver recebendo erro de constraint
-- na coluna status ao criar metas

-- Remover constraint antiga se existir
ALTER TABLE goals DROP CONSTRAINT IF EXISTS goals_status_check;

-- Recriar constraint corretamente
ALTER TABLE goals ADD CONSTRAINT goals_status_check 
CHECK (status IN ('ongoing', 'completed'));

-- Verificar se a tabela tem a estrutura correta
-- Se não tiver, pode ser necessário recriar

-- Verificar se há dados com status inválido
SELECT id, name, status 
FROM goals 
WHERE status NOT IN ('ongoing', 'completed');

-- Se houver dados inválidos, corrigir (exemplo):
-- UPDATE goals SET status = 'ongoing' WHERE status NOT IN ('ongoing', 'completed');

-- =====================================================
-- FIM DA CORREÇÃO
-- =====================================================

