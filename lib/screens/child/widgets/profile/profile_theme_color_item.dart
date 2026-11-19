import 'package:flutter/material.dart';

import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/drawer/child_drawer_theme_swatches.dart';

/// Item "Cor do app" das configurações do Perfil (DECISOES 13).
///
/// Mesmo desenho dos vizinhos (`ProfileSettingItem`): caixa do ícone, título e
/// subtítulo (o nome da cor atual). Embaixo ficam as 3 bolinhas do menu
/// lateral. Trocar aqui vale na hora para toda a área da criança.
///
/// O Perfil segue o tema do app (pode estar escuro), então os textos usam as
/// cores do tema da tela, como os itens vizinhos.
class ProfileThemeColorItem extends StatelessWidget {
  const ProfileThemeColorItem({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = ChildThemeColorController.of(context);
    final tema = Theme.of(context);
    final cor = cores.tema;
    final corTitulo = tema.textTheme.titleMedium?.color ?? LummyColors.ink900;
    final corApoio = tema.textTheme.bodyMedium?.color ?? LummyColors.ink600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.palette_rounded, color: cor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cor do app',
                      style: LummyFonts.body(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: corTitulo,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cores.opcao.label,
                      style: LummyFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: corApoio,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ChildThemeColorSwatches(
            corRotuloEscolhido: corTitulo,
            corRotulo: corApoio,
            // O vão do anel acompanha o fundo do cartão (claro ou escuro).
            corDoVao: tema.cardTheme.color ?? tema.scaffoldBackgroundColor,
          ),
        ],
      ),
    );
  }
}
