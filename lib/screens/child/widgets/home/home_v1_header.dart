import 'package:flutter/material.dart';

import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/theme/lummy_cores.dart';
import 'package:lummy/data/child/child_missions_repository.dart';
import 'package:lummy/screens/child/widgets/v1/v1.dart';

/// Cabeçalho da Home (`Main.dc.html`, `<header>`): avatar 44 (abre o menu
/// lateral), saudação, pílula de sequência e sininho. Linha centralizada com
/// `gap: 12px`.
///
/// Desvios do mockup (DECISOES 7, nada de número inventado):
/// - o subtítulo "Exploradora" não aparece (não existe esse dado);
/// - o ponto laranja do sininho não aparece (não há contador de não lidas);
/// - a pílula de sequência só aparece com 1 dia ou mais.
class HomeV1Header extends StatelessWidget {
  const HomeV1Header({
    super.key,
    required this.primeiroNome,
    required this.streak,
    required this.onNotificacoesTap,
  });

  /// Primeiro nome da criança. Vazio enquanto o perfil não chegou.
  final String primeiroNome;

  /// Sequência de dias (nula ou 0 = sem pílula).
  final ChildStreak? streak;

  final VoidCallback onNotificacoesTap;

  @override
  Widget build(BuildContext context) {
    final nome = primeiroNome.trim();
    final dias = streak?.diasSeguidos ?? 0;

    return Row(
      children: [
        // Altura do mockup com "Exploradora" (25,3 + 1 + 20): o subtítulo está
        // escondido (D7), mas o resto da tela fica no lugar do mockup.
        const SizedBox(height: 46.3),
        const ChildAvatar(size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              nome.isEmpty ? 'Oi!' : 'Oi, $nome!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LummyText.saudacao(context),
            ),
          ),
        ),
        if (dias > 0) ...[
          const SizedBox(width: 12),
          _PilulaSequencia(dias: dias),
        ],
        const SizedBox(width: 12),
        _Sininho(onTap: onNotificacoesTap),
      ],
    );
  }
}

/// Pílula "5 dias": altura 36, padding `0 12`, raio 18, fundo `#F2F4F7`,
/// chama laranja preenchida 16 + Poppins 600 13 tinta, `gap: 5px`.
class _PilulaSequencia extends StatelessWidget {
  const _PilulaSequencia({required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    final texto = dias == 1 ? '1 dia' : '$dias dias';
    return Semantics(
      label: dias == 1 ? 'Sequência de 1 dia' : 'Sequência de $dias dias',
      excludeSemantics: true,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.cores.superficieNeutra,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LummyIcon(
              LummyGlyphs.flame,
              size: 16,
              color: LummyColors.orange600,
              fill: LummyColors.orange600,
              strokeWidth: 2,
            ),
            const SizedBox(width: 5),
            Text(
              texto,
              maxLines: 1,
              softWrap: false,
              style: LummyText.poppins(context, size: 13, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão 44×44 circular `#F2F4F7` com o sino 21 tinta.
class _Sininho extends StatelessWidget {
  const _Sininho({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LummyPressable(
      onTap: onTap,
      semanticLabel: 'Notificações',
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.cores.superficieNeutra,
          shape: BoxShape.circle,
        ),
        child: LummyIcon(
          LummyGlyphs.bell,
          size: 21,
          color: context.cores.tinta,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
