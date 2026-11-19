-- "Precisava ou queria" no gasto da criança (redesenho infantil V1).
-- Nula em registros antigos e em não-despesas. Sem backfill.
ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS need_or_want TEXT NULL
  CHECK (need_or_want IN ('need', 'want'));

COMMENT ON COLUMN public.transactions.need_or_want IS
  'Gasto de precisa (need) ou de quer (want). Nulo em registros antigos e em não-despesas.';
