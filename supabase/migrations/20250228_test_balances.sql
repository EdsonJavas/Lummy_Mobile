-- Zera o saldo de todos os filhos (ambiente de teste)
UPDATE children SET balance = 0;

-- Garante que a coluna balance existe em responsaveis com default 2300
ALTER TABLE responsaveis
  ADD COLUMN IF NOT EXISTS balance NUMERIC(12,2) NOT NULL DEFAULT 2300.00;

-- Define 2300 para todos os responsaveis que ainda nao tem saldo
UPDATE responsaveis SET balance = 2300.00 WHERE balance = 0 OR balance IS NULL;
