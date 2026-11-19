import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/data/child/child_transactions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';
import 'package:lummy/shared/widgets/lummy_feedback.dart';

import 'money_sheet_amount.dart';
import 'money_sheet_category_grid.dart';
import 'money_sheet_frame.dart';
import 'money_sheet_keypad.dart';

/// Painel "Registrar dinheiro que ganhei" (D18). Não tem mockup: segue o de
/// gasto ao pé da letra (mesma moldura, visor e teclado), com "De onde veio?"
/// no lugar das categorias e sem "Você precisava ou só queria?".
///
/// Linha do visor (decisão do líder, por cima do D18): pela regra atual o
/// ganho NÃO soma ao saldo (`registrarGanho` grava como a tela antiga), então
/// "Depois disso, você fica com R$ X" seria falso. Mostra "Fica registrado no
/// seu histórico." e não há estado de saldo insuficiente. Se o dono decidir
/// creditar o saldo, a frase volta a ser a do D18.
class MoneySheetIncome extends StatefulWidget {
  const MoneySheetIncome({super.key});

  @override
  State<MoneySheetIncome> createState() => _MoneySheetIncomeState();
}

class _MoneySheetIncomeState extends State<MoneySheetIncome> {
  final _repositorio = ChildTransactionsRepository();

  static final List<MoneySheetOption> _origens = ChildIncomeOrigins.todas
      .map(MoneySheetOption.origem)
      .toList(growable: false);

  var _entrada = const MoneySheetAmountInput();
  MoneySheetOption? _origem;
  bool _salvando = false;

  void _digitar(MoneySheetAmountInput nova) {
    if (nova.cru == _entrada.cru) return;
    setState(() => _entrada = nova);
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    final valor = _entrada.valor;
    if (valor <= 0) {
      LummyFeedback.warning(context, 'Informe um valor válido');
      return;
    }
    final origem = _origem;
    if (origem == null) {
      LummyFeedback.warning(context, 'Selecione de onde veio');
      return;
    }

    // Lido antes do await: o aviso vale mesmo se o painel sumir no caminho.
    final mudancas = context.read<ChildDataChanges>();
    setState(() => _salvando = true);

    final resultado = await _repositorio.registrarGanho(
      valor: valor,
      origemId: origem.id,
      descricao: origem.nome,
    );

    if (resultado == SaveMoneyResult.ok) {
      mudancas.avisar({ChildDataKind.saldo});
    }
    if (!mounted) return;

    switch (resultado) {
      case SaveMoneyResult.ok:
        Navigator.pop(context, true);
      case SaveMoneyResult.valorInvalido:
        setState(() => _salvando = false);
        LummyFeedback.warning(context, 'Informe um valor válido');
      case SaveMoneyResult.saldoInsuficiente:
      case SaveMoneyResult.semSessao:
      case SaveMoneyResult.erro:
        setState(() => _salvando = false);
        LummyFeedback.error(context, 'Não foi possível registrar. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MoneySheetFrame(
      titulo: 'Registrar dinheiro que ganhei',
      bloqueado: _salvando,
      corpo: [
        const SizedBox(height: 4),
        MoneySheetAmountDisplay(
          valor: _entrada.texto,
          linha: 'Fica registrado no seu histórico.',
        ),
        const SizedBox(height: 16),
        Text('De onde veio?', style: LummyText.pergunta()),
        const SizedBox(height: 10),
        MoneySheetOptionGrid(
          opcoes: _origens,
          escolhidaId: _origem?.id,
          habilitado: !_salvando,
          onEscolher: (o) => setState(() => _origem = o),
        ),
        const SizedBox(height: 12),
        MoneySheetKeypad(
          habilitado: !_salvando,
          onDigito: (d) => _digitar(_entrada.comDigito(d)),
          onVirgula: () => _digitar(_entrada.comVirgula()),
          onApagar: () => _digitar(_entrada.apagar()),
          onLimpar: () => _digitar(const MoneySheetAmountInput()),
        ),
      ],
      rodape: LummyWideButton(
        rotulo: 'Salvar',
        carregando: _salvando,
        onTap: _salvar,
      ),
    );
  }
}
