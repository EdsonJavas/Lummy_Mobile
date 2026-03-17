-- Habilita Realtime na tabela children para o app infantil receber
-- atualizações de saldo em tempo real (e notificação ao receber dinheiro).
-- Execute no SQL Editor do Supabase se a migração não rodar automaticamente.
ALTER PUBLICATION supabase_realtime ADD TABLE public.children;
