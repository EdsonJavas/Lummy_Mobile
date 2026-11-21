import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

import 'home_educational_tips.dart';

/// "Dica do Lummy" (`Home-rolagem.dc.html`, `<section aria-label="Dica do
/// Lummy">`): o astronauta num círculo espacial de 56 e um balão cinza com a
/// dica.
///
/// O texto vem da lista que o app já tinha (`buildHomeEducationalTips`): a
/// dica do dia é `diaDoAno % total` (igual o dia inteiro). Tocar no balão
/// passa para a próxima.
class HomeBTip extends StatefulWidget {
  const HomeBTip({super.key});

  @override
  State<HomeBTip> createState() => _HomeBTipState();
}

class _HomeBTipState extends State<HomeBTip> {
  late final List<EducationalTip> _dicas = buildHomeEducationalTips();
  late int _indice = _indiceDoDia();

  int _indiceDoDia() {
    if (_dicas.isEmpty) return 0;
    final agora = DateTime.now();
    final diaDoAno = DateTime(agora.year, agora.month, agora.day)
            .difference(DateTime(agora.year))
            .inHours ~/
        24;
    return diaDoAno % _dicas.length;
  }

  void _proxima() {
    if (_dicas.length < 2) return;
    setState(() => _indice = (_indice + 1) % _dicas.length);
  }

  @override
  Widget build(BuildContext context) {
    if (_dicas.isEmpty) return const SizedBox.shrink();
    final tema = ChildThemeColorController.of(context).tema;
    final texto = _dicas[_indice].content;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const _AvatarLummy(),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Dica do Lummy: $texto',
            hint: 'Toque para ver outra dica',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _proxima,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.cores.superficieNeutra,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dica do Lummy',
                      style: LummyText.poppins(
                        context,
                        size: 12,
                        weight: FontWeight.w600,
                        color: context.cores.realce(tema),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.topLeft,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        layoutBuilder: (atual, anteriores) => Stack(
                          alignment: Alignment.topLeft,
                          children: [...anteriores, ?atual],
                        ),
                        child: SizedBox(
                          key: ValueKey(_indice),
                          width: double.infinity,
                          child: Text(
                            texto,
                            style: LummyText.poppins(context, size: 14, height: 1.45),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Círculo 56×56 com o fundo "espaço" (brilho a 70%/25% até 70%, sem
/// estrelas) e o astronauta 42×54 embaixo, descendo 6 px (cortado pelo círculo).
class _AvatarLummy extends StatelessWidget {
  const _AvatarLummy();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 56,
        height: 56,
        child: SpaceBackground(
          circle: true,
          glowCenter: const Offset(0.7, 0.25),
          glowStop: 0.7,
          child: SizedBox.expand(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: const Offset(0, 6),
                child: const LummyAstronaut(width: 42, height: 54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
