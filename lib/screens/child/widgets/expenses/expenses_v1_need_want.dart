import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'expenses_v1_calc.dart';

/// "Precisava ou queria?" (`Gastos-mes.dc.html` + `Gastos-lista.dc.html`):
/// barra de 2 segmentos (tema e laranja), legenda com valor e percentual, e a
/// frase de atenção quando "Queria" passa da metade.
///
/// A tela só monta este widget se a coluna existir no banco e houver gasto
/// classificado no período (DECISOES 7 e 11).
class ExpensesV1NeedWant extends StatelessWidget {
  const ExpensesV1NeedWant({super.key, required this.dados});

  final ExpensesNeedWant dados;

  @override
  Widget build(BuildContext context) {
    final tema = ChildThemeColorController.of(context).tema;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(titulo: 'Precisava ou queria?'),
        const SizedBox(height: 12),
        ExcludeSemantics(child: _Barra(dados: dados, tema: tema)),
        const SizedBox(height: 12),
        _Legenda(
          cor: tema,
          rotulo: 'Precisava',
          valor: dados.precisava,
          porcento: dados.porcentoPrecisava,
        ),
        const SizedBox(height: 8),
        _Legenda(
          cor: LummyColors.orange600,
          rotulo: 'Queria',
          valor: dados.queria,
          porcento: dados.porcentoQueria,
        ),
        if (dados.maisDaMetadeQueria) ...[
          const SizedBox(height: 12),
          Text(
            'Mais da metade foi com coisas que você queria. '
            'Tudo bem querer, só vale ficar de olho.',
            style: LummyText.poppins(size: 13, height: 1.45, color: LummyColors.ink600),
          ),
        ],
      ],
    );
  }
}

/// Barra de 10 de altura: `display: flex; gap: 2px`; o primeiro segmento tem a
/// largura da fração de "Precisava" e o segundo ocupa o resto. Segmento de 0%
/// não aparece (nem o vão).
class _Barra extends StatelessWidget {
  const _Barra({required this.dados, required this.tema});

  final ExpensesNeedWant dados;
  final Color tema;

  static const _altura = 10.0;
  static const _vao = 2.0;

  @override
  Widget build(BuildContext context) {
    final temPrecisava = dados.precisava > 0;
    final temQueria = dados.queria > 0;

    return LayoutBuilder(
      builder: (context, box) {
        final largura = box.maxWidth;
        final double larguraPrecisava;
        if (!temPrecisava) {
          larguraPrecisava = 0;
        } else if (!temQueria) {
          larguraPrecisava = largura;
        } else {
          // Como no CSS: `width: 40%` do total; o vão sai do segundo segmento.
          final maximo = largura > _vao ? largura - _vao : 0.0;
          larguraPrecisava =
              (largura * dados.fracaoPrecisava).clamp(0.0, maximo).toDouble();
        }

        return SizedBox(
          height: _altura,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: larguraPrecisava,
                decoration: BoxDecoration(
                  color: tema,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (temPrecisava && temQueria) const SizedBox(width: _vao),
              if (temQueria)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: LummyColors.orange600,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({
    required this.cor,
    required this.rotulo,
    required this.valor,
    required this.porcento,
  });

  final Color cor;
  final String rotulo;
  final double valor;
  final int porcento;

  @override
  Widget build(BuildContext context) {
    final valorTexto = V1Format.brl(valor);

    return Semantics(
      label: '$rotulo: $valorTexto, $porcento por cento',
      excludeSemantics: true,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(rotulo, style: LummyText.poppins(size: 14))),
          const SizedBox(width: 8),
          Text(
            valorTexto,
            maxLines: 1,
            softWrap: false,
            style: LummyText.poppins(size: 14, weight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$porcento%',
              textAlign: TextAlign.right,
              maxLines: 1,
              softWrap: false,
              style: LummyText.poppins(size: 14, color: LummyColors.ink600),
            ),
          ),
        ],
      ),
    );
  }
}
