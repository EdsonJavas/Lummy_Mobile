import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Diálogo que pergunta se o usuário quer ativar o login por digital.
/// Fecha retornando true (ativar) ou false (agora não).
class LoginBiometricSetupDialog extends StatelessWidget {
  const LoginBiometricSetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(28),
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(color: LummyColors.slate600, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de biometria
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          LummyColors.blue500.withValues(alpha: 0.2),
                          LummyColors.violet500.withValues(alpha: 0.1),
                        ]
                      : [
                          LummyColors.blue800.withValues(alpha: 0.1),
                          LummyColors.violet500.withValues(alpha: 0.05),
                        ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? LummyColors.blue500.withValues(alpha: 0.3)
                      : LummyColors.blue800.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.fingerprint,
                size: 64,
                color: Theme.of(context).brightness == Brightness.dark
                    ? LummyColors.blue500
                    : LummyColors.blue800,
              ),
            ),
            const SizedBox(height: 24),
            // Título
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [LummyColors.blue500, LummyColors.violet500]
                    : [LummyColors.slate800, LummyColors.slate800],
              ).createShader(bounds),
              child: Text(
                'Ativar Biometria?',
                style: LummyFonts.body(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            // Descrição
            Text(
              'Salve sua digital para fazer login de forma rápida e segura nos próximos acessos!',
              style: LummyFonts.body(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // Botões
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? LummyColors.slate700
                          : LummyColors.slate100,
                      foregroundColor: Theme.of(context).brightness == Brightness.dark
                          ? LummyColors.slate200
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                              ? LummyColors.slate600
                              : LummyColors.slate200,
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Agora Não',
                      style: LummyFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LummyColors.blue500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Ativar',
                      style: LummyFonts.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
