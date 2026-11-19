import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/theme/app_theme.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/data/child/child_goals_repository.dart';
import 'package:lummy/screens/child/new_goal_screen.dart';
import 'package:lummy/shared/widgets/lummy_feedback.dart';

/// Fluxo ÚNICO de criar meta, usado por todos os pontos de entrada da criança
/// ("Nova meta" e "Criar uma meta" da Home; "Criar minha meta" de Metas).
///
/// 1. Se já existe meta em andamento, avisa e não abre nada (uma meta por vez).
/// 2. Abre `NewGoalScreen` (contrato `{name, emoji, amount}`, não mudar).
/// 3. Grava com `ChildGoalsRepository.criarMeta` (corrige o bug do D8: a Home
///    só recarregava e dizia "Nova meta criada!" sem gravar).
/// 4. Avisa `ChildDataChanges` ({meta}) para Home e Metas recarregarem.
///
/// Devolve true se a meta foi criada. Quem chama não precisa recarregar à mão
/// se já escuta `ChildDataChanges`.
Future<bool> abrirCriacaoDeMeta(BuildContext context) async {
  // Dois toques rápidos abririam duas telas de Nova meta (a checagem abaixo
  // espera o banco antes de abrir).
  if (_abrindoCriacaoDeMeta) return false;
  _abrindoCriacaoDeMeta = true;
  try {
    return await _abrirCriacaoDeMeta(context);
  } finally {
    _abrindoCriacaoDeMeta = false;
  }
}

bool _abrindoCriacaoDeMeta = false;

Future<bool> _abrirCriacaoDeMeta(BuildContext context) async {
  final repo = ChildGoalsRepository();
  final changes = context.read<ChildDataChanges>();

  try {
    if (await repo.buscarMetaAtual() != null) {
      if (!context.mounted) return false;
      LummyFeedback.warning(
        context,
        'Você já tem uma meta. Conquiste ou desista dela para criar outra.',
      );
      return false;
    }
  } catch (e) {
    // Sem conseguir checar, segue: o banco recusa a segunda meta (índice único)
    // e criarMeta devolve jaExisteMeta.
    appLog('⚠️ Criar meta: não deu para checar meta atual: $e');
  }

  if (!context.mounted) return false;
  final result = await Navigator.of(context).push<Object?>(
    // Área da criança sempre clara (D12), também nesta tela empurrada.
    MaterialPageRoute(
      builder: (_) =>
          Theme(data: AppTheme.lightTheme, child: const NewGoalScreen()),
    ),
  );
  if (result is! Map || !context.mounted) return false;

  final nome = (result['name'] ?? '').toString();
  final emoji = (result['emoji'] ?? '🎯').toString();
  final valor = (result['amount'] as num?)?.toDouble() ?? 0;

  final status = await repo.criarMeta(nome: nome, emoji: emoji, valorAlvo: valor);
  if (!context.mounted) return status == CriarMetaResultado.criada;

  switch (status) {
    case CriarMetaResultado.criada:
      changes.avisar({ChildDataKind.meta});
      LummyFeedback.success(context, 'Nova meta criada! 🎯');
      return true;
    case CriarMetaResultado.jaExisteMeta:
      LummyFeedback.warning(
        context,
        'Você já tem uma meta. Conquiste ou desista dela para criar outra.',
      );
    case CriarMetaResultado.semRegistro:
      LummyFeedback.error(
        context,
        'Não encontramos seu cadastro. Peça ajuda a um responsável.',
      );
    case CriarMetaResultado.dadosInvalidos:
      LummyFeedback.warning(context, 'Confira o nome e o valor da meta.');
    case CriarMetaResultado.semSessao:
    case CriarMetaResultado.erro:
      LummyFeedback.error(
        context,
        'Não foi possível criar a meta. Verifique a internet e tente de novo.',
      );
  }
  return false;
}
