import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lummy/core/providers/child_data_changes.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/network_errors.dart';
import 'package:lummy/data/child/child_transactions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';
import 'package:lummy/shared/widgets/lummy_feedback.dart';

import 'money_sheet_amount.dart';
import 'money_sheet_category_grid.dart';
import 'money_sheet_frame.dart';
import 'money_sheet_keypad.dart';

/// Painel "Anotar gasto" (`Anotar-gasto.dc.html`, D17).
///
/// Lê sozinho o saldo e as categorias liberadas pelos pais. Fecha com `true`
/// depois de gravar (e de avisar `ChildDataChanges`); `false` nos demais casos.
class MoneySheetExpense extends StatefulWidget {
  const MoneySheetExpense({super.key, this.saldoAtual});

  /// Saldo que quem abriu já conhece: só para a primeira pintura.
  final double? saldoAtual;

  @override
  State<MoneySheetExpense> createState() => _MoneySheetExpenseState();
}

class _MoneySheetExpenseState extends State<MoneySheetExpense> {
  final _repositorio = ChildTransactionsRepository();

  static const _segmentos = [
    LummySegment(NeedOrWant.need, 'Precisava'),
    LummySegment(NeedOrWant.want, 'Queria'),
  ];

  var _entrada = const MoneySheetAmountInput();
  double? _saldo;

  /// Nulo enquanto o contexto não chegou.
  List<MoneySheetOption>? _categorias;
  bool _erroContexto = false;

  MoneySheetOption? _categoria;
  NeedOrWant? _needOrWant;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _saldo = widget.saldoAtual;
    _carregarContexto();
  }

  Future<void> _carregarContexto() async {
    if (_erroContexto) setState(() => _erroContexto = false);
    try {
      final contexto = await _repositorio.carregarContexto();
      if (!mounted) return;
      final categorias = ChildCategories.permitidas(contexto.categoriasPermitidas)
          .map(MoneySheetOption.categoria)
          .toList(growable: false);
      setState(() {
        _saldo = contexto.saldo;
        _categorias = categorias;
        // A categoria escolhida pode ter deixado de ser permitida.
        final escolhida = _categoria;
        if (escolhida != null && !categorias.any((c) => c.id == escolhida.id)) {
          _categoria = null;
        }
      });
    } catch (e, st) {
      debugLogDataLoad('Painel de gasto: contexto', e, st);
      if (!mounted) return;
      // Se as categorias já estavam na tela (recarga depois de "saldo
      // insuficiente"), mantém o que havia em vez de trocar pela tela de erro.
      if (_categorias == null) setState(() => _erroContexto = true);
    }
  }

  bool get _saldoInsuficiente {
    final saldo = _saldo;
    return saldo != null && _entrada.valor > saldo;
  }

  String? get _linhaDoValor {
    final saldo = _saldo;
    if (saldo == null) return null;
    if (_saldoInsuficiente) return 'Seu cofrinho tem ${V1Format.brl(saldo)}';
    return 'Depois disso, sobram ${V1Format.brl(saldo - _entrada.valor)}';
  }

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
    final categoria = _categoria;
    if (categoria == null) {
      LummyFeedback.warning(context, 'Selecione uma categoria');
      return;
    }

    // Lido antes do await: o aviso vale mesmo se o painel sumir no caminho.
    final mudancas = context.read<ChildDataChanges>();
    setState(() => _salvando = true);

    final resultado = await _repositorio.registrarGasto(
      valor: valor,
      categoriaId: categoria.id,
      descricao: categoria.nome,
      needOrWant: _needOrWant,
    );

    if (resultado == SaveMoneyResult.ok) {
      mudancas.avisar({ChildDataKind.saldo, ChildDataKind.gastos});
    }
    if (!mounted) return;

    switch (resultado) {
      case SaveMoneyResult.ok:
        Navigator.pop(context, true);
      case SaveMoneyResult.saldoInsuficiente:
        setState(() => _salvando = false);
        LummyFeedback.warning(context, 'Saldo insuficiente.');
        // O saldo mudou desde que o painel abriu.
        await _carregarContexto();
      case SaveMoneyResult.valorInvalido:
        setState(() => _salvando = false);
        LummyFeedback.warning(context, 'Informe um valor válido');
      case SaveMoneyResult.semSessao:
      case SaveMoneyResult.erro:
        setState(() => _salvando = false);
        LummyFeedback.error(context, 'Não foi possível registrar. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = _categorias;
    final podeSalvar = !_erroContexto && !_saldoInsuficiente;

    return MoneySheetFrame(
      titulo: 'Anotar gasto',
      bloqueado: _salvando,
      corpo: [
        const SizedBox(height: 4),
        MoneySheetAmountDisplay(
          valor: _entrada.texto,
          linha: _linhaDoValor,
          corLinha: _saldoInsuficiente ? LummyColors.danger700 : LummyColors.ink600,
        ),
        const SizedBox(height: 16),
        Text('Com o quê?', style: LummyText.pergunta()),
        const SizedBox(height: 10),
        if (_erroContexto)
          _ErroCategorias(onTentarDeNovo: _carregarContexto)
        else if (categorias == null)
          const MoneySheetOptionGridPlaceholder()
        else
          MoneySheetOptionGrid(
            opcoes: categorias,
            escolhidaId: _categoria?.id,
            habilitado: !_salvando,
            onEscolher: (c) => setState(() => _categoria = c),
          ),
        const SizedBox(height: 16),
        Text('Você precisava ou só queria?', style: LummyText.pergunta()),
        const SizedBox(height: 10),
        IgnorePointer(
          ignoring: _salvando,
          child: LummySegmented<NeedOrWant>(
            opcoes: _segmentos,
            selecionado: _needOrWant,
            tamanho: LummySegmentedSize.grande,
            semanticLabel: 'Você precisava ou só queria?',
            // Opcional: tocar na marcada desmarca.
            onChanged: (v) => setState(() => _needOrWant = _needOrWant == v ? null : v),
          ),
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
        rotulo: 'Salvar gasto',
        carregando: _salvando,
        onTap: podeSalvar ? _salvar : null,
      ),
    );
  }
}

/// No lugar da grade quando o contexto não carrega.
class _ErroCategorias extends StatelessWidget {
  const _ErroCategorias({required this.onTentarDeNovo});

  final VoidCallback onTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ChildThemeColorController>().tema;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Não foi possível carregar suas categorias.',
          textAlign: TextAlign.center,
          style: LummyText.apoio(),
        ),
        TextButton(
          onPressed: onTentarDeNovo,
          style: TextButton.styleFrom(
            foregroundColor: tema,
            minimumSize: const Size(48, 44),
            textStyle: LummyText.link(tema),
          ),
          child: const Text('Tentar de novo'),
        ),
      ],
    );
  }
}
