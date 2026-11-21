import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Uma opção da grade do painel: categoria de gasto ou origem de ganho.
@immutable
class MoneySheetOption {
  const MoneySheetOption({
    required this.id,
    required this.nome,
    required this.glyph,
    required this.tracoNormal,
    required this.tracoEscolhida,
  });

  /// Categoria de gasto: traço 2 (2.1 escolhida); "Outros" sai 2.4.
  factory MoneySheetOption.categoria(ChildExpenseCategory c) => MoneySheetOption(
        id: c.id,
        nome: c.nome,
        glyph: c.glyph,
        tracoNormal: c.traco(2),
        tracoEscolhida: c.traco(2.1),
      );

  /// Origem de ganho (D18): mesmo desenho da categoria.
  factory MoneySheetOption.origem(ChildIncomeOrigin o) => MoneySheetOption(
        id: o.id,
        nome: o.nome,
        glyph: o.glyph,
        tracoNormal: o.traco(2),
        tracoEscolhida: o.traco(2.1),
      );

  final String id;
  final String nome;
  final LummyGlyph glyph;
  final double tracoNormal;
  final double tracoEscolhida;
}

/// Grade "Com o quê?" (`Anotar-gasto.dc.html`): 4 colunas iguais,
/// `column-gap: 8px`, `row-gap: 10px`.
///
/// Cada botão é uma coluna centralizada com `gap: 6px`: quadrado 48×48 raio 16
/// (escolhida laranja com ícone branco; as outras `#F2F4F7` com ícone tinta) e
/// o nome em Poppins 12 (escolhida 600 tinta; as outras 500 `#5B6478`).
///
/// Feita com `Row`/`Column` (e não `GridView`) para funcionar dentro do
/// `IntrinsicHeight` do `MoneySheetFrame`.
class MoneySheetOptionGrid extends StatelessWidget {
  const MoneySheetOptionGrid({
    super.key,
    required this.opcoes,
    required this.escolhidaId,
    required this.onEscolher,
    this.habilitado = true,
  });

  final List<MoneySheetOption> opcoes;
  final String? escolhidaId;
  final ValueChanged<MoneySheetOption> onEscolher;

  /// false = ignora toques (durante a gravação).
  final bool habilitado;

  static const colunas = 4;
  static const gapColuna = 8.0;
  static const gapLinha = 10.0;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !habilitado,
      child: _GradeQuatroColunas(
        quantidade: opcoes.length,
        itemBuilder: (i) {
          final opcao = opcoes[i];
          return _BotaoOpcao(
            opcao: opcao,
            escolhida: opcao.id == escolhidaId,
            onTap: () => onEscolher(opcao),
          );
        },
      ),
    );
  }
}

/// Enquanto o contexto carrega: quadrados `#F2F4F7` vazios, no mesmo tamanho
/// da grade final (não há pulo de layout quando as categorias chegam).
class MoneySheetOptionGridPlaceholder extends StatelessWidget {
  const MoneySheetOptionGridPlaceholder({super.key, this.quantidade = 8});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: _GradeQuatroColunas(
        quantidade: quantidade,
        itemBuilder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Quadrado(cor: context.cores.superficieNeutra),
            const SizedBox(height: 6),
            // Mesmo estilo do rótulo: reserva a altura exata da linha.
            Text(
              ' ',
              style: LummyText.poppins(context, size: 12, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeQuatroColunas extends StatelessWidget {
  const _GradeQuatroColunas({required this.quantidade, required this.itemBuilder});

  final int quantidade;
  final Widget Function(int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    const colunas = MoneySheetOptionGrid.colunas;
    final linhas = (quantidade / colunas).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var l = 0; l < linhas; l++) ...[
          if (l > 0) const SizedBox(height: MoneySheetOptionGrid.gapLinha),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < colunas; c++) ...[
                if (c > 0) const SizedBox(width: MoneySheetOptionGrid.gapColuna),
                Expanded(
                  child: l * colunas + c < quantidade
                      ? itemBuilder(l * colunas + c)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Quadrado extends StatelessWidget {
  const _Quadrado({required this.cor, this.child});

  final Color cor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _BotaoOpcao extends StatelessWidget {
  const _BotaoOpcao({
    required this.opcao,
    required this.escolhida,
    required this.onTap,
  });

  final MoneySheetOption opcao;
  final bool escolhida;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: escolhida,
      label: opcao.nome,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Quadrado(
              cor: escolhida ? LummyColors.orange600 : context.cores.superficieNeutra,
              child: LummyIcon(
                opcao.glyph,
                size: 22,
                color: escolhida ? LummyColors.white : context.cores.tinta,
                strokeWidth: escolhida ? opcao.tracoEscolhida : opcao.tracoNormal,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: LummyText.poppins(
                context,
                size: 12,
                weight: escolhida ? FontWeight.w600 : FontWeight.w500,
                color: escolhida ? context.cores.tinta : context.cores.tintaApoio,
              ),
              child: Text(
                opcao.nome,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
