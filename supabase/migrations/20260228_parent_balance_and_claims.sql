-- Saldo do responsavel separado (teste: 2300) e filhos zerados
ALTER TABLE responsaveis
  ADD COLUMN IF NOT EXISTS balance NUMERIC(12,2) NOT NULL DEFAULT 2300.00;

ALTER TABLE children
  ADD COLUMN IF NOT EXISTS balance NUMERIC(12,2) NOT NULL DEFAULT 0.00;

UPDATE responsaveis
SET balance = 2300.00;

UPDATE children
SET balance = 0.00;

-- Distribuicao para resgate por score
CREATE TABLE IF NOT EXISTS allowance_distributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES responsaveis(id) ON DELETE CASCADE,
  total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount > 0),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'closed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_allowance_distributions_parent_status
  ON allowance_distributions(parent_id, status, created_at DESC);

-- Cada filho pode resgatar no maximo uma vez por distribuicao
CREATE TABLE IF NOT EXISTS allowance_claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  distribution_id UUID NOT NULL REFERENCES allowance_distributions(id) ON DELETE CASCADE,
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(distribution_id, child_id)
);

CREATE INDEX IF NOT EXISTS idx_allowance_claims_distribution
  ON allowance_claims(distribution_id, created_at DESC);
