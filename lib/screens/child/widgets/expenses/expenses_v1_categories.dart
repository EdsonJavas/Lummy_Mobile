import 'package:flutter/material.dart';

import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'expenses_v1_calc.dart';

/// "Onde foi seu dinheiro" (`Gastos-mes.dc.html`): uma linha por categoria com
/// ícone neutro, nome, valor e barra da fatia. Tocar filtra "Últimos gastos".
class ExpensesV1Categories extends StatelessWidget {
  const ExpensesV1Categories({
    super.key,
    required this.categorias,
    required this.selecionadaId,
    required this.onTap,
  });

  final List<ExpensesCategoryTotal> categorias;

  /// Id da categoria que está filtrando a lista (nulo = nenhuma).
  final String? selecionadaId;

  /// Recebe o id tocado; a tela decide se marca ou limpa.
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final vazio = categorias.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          titulo: 'Onde foi seu dinheiro',
          // Sem gastos (não desenhado): a frase troca de lugar com o apoio.
          apoio: vazio
              ? 'Nenhum gasto neste período.'
              : 'Toque numa categoria para ver só os gastos dela.',
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: vazio
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      for (var i = 0; i < categorias.length; i++) ...[
                        if (i > 0) const SizedBox(height: 4),
                        _CategoriaItem(
                          key: ValueKey(categorias[i].categoria.id),
                          item: categorias[i],
                          selecionada: categorias[i].categoria.id == selecionadaId,
                          onTap: () => onTap(categorias[i].categoria.id),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _CategoriaItem extends StatelessWidget {
  const _CategoriaItem({
    super.key,
    required this.item,
    required this.selecionada,
    required this.onTap,
  });

  final ExpensesCategoryTotal item;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = item.categoria;
    final valor = V1Format.brl(item.valor);
    final estilo = LummyText.poppins(context, size: 14, weight: FontWeight.w600);

    return Semantics(
      button: true,
      selected: selecionada,
      label: '${cat.nome}, $valor',
      hint: selecionada ? 'Toque para ver todos os gastos' : 'Toque para ver só estes gastos',
      excludeSemantics: true,
      child: LummyPressable(
        onTap: onTap,
        pressedScale: 0.98,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              // Selecionada (não desenhado): borda 2 azul-escuro no quadrado.
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    width: 2,
                    color: selecionada
                        ? context.cores.grafico
                        : context.cores.grafico.withValues(alpha: 0),
                  ),
                ),
                child: NeutralIconTile(
                  glyph: cat.glyph,
                  size: 40,
                  radius: 14,
                  iconSize: 20,
                  strokeWidth: cat.traco(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            cat.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: estilo,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(valor, maxLines: 1, softWrap: false, style: estilo),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ThinProgressBar(valor: item.fracao, cor: context.cores.grafico),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
