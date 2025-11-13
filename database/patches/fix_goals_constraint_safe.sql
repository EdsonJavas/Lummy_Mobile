-- =====================================================
-- CORREÇÃO ALTERNATIVA: Corrigir constraint sem perder dados
-- =====================================================
-- Execute este script se NÃO quiser perder os dados existentes
-- Isso apenas corrige a constraint sem deletar a tabela

-- 1. Verificar estrutura atual
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'goals'
ORDER BY ordinal_position;

-- 2. Verificar constraint atual
SELECT constraint_name, constraint_type, check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'goals';

-- 3. Corrigir qualquer status inválido primeiro (se houver)
UPDATE goals 
SET status = 'ongoing' 
WHERE status IS NULL OR status NOT IN ('ongoing', 'completed');

-- 4. Garantir que emoji não seja NULL
UPDATE goals 
SET emoji = '🎯' 
WHERE emoji IS NULL OR emoji = '';

-- 5. Remover constraint antiga se existir
ALTER TABLE goals DROP CONSTRAINT IF EXISTS goals_status_check;

-- 6. Adicionar constraint correta
ALTER TABLE goals ADD CONSTRAINT goals_status_check 
CHECK (status IN ('ongoing', 'completed'));

-- 7. Garantir que name não seja NULL ou vazio
UPDATE goals 
SET name = 'Meta sem nome' 
WHERE name IS NULL OR name = '';

-- 8. Garantir que emoji não seja NULL (novamente, com NOT NULL)
ALTER TABLE goals ALTER COLUMN emoji SET NOT NULL;
ALTER TABLE goals ALTER COLUMN emoji SET DEFAULT '🎯';

-- 9. Verificar se tudo está correto
SELECT id, name, emoji, status, current_amount, target_amount
FROM goals
LIMIT 10;

-- =====================================================
-- FIM DA CORREÇÃO ALTERNATIVA
-- =====================================================

