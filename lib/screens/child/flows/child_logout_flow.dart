import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lummy/application/app_facade.dart';
import 'package:lummy/core/providers/child_profile_controller.dart';
import 'package:lummy/core/providers/child_theme_color_controller.dart';
import 'package:lummy/core/providers/theme_provider.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/di/locator.dart';
import 'package:lummy/domain/repositories/auth_repository.dart';
import 'package:lummy/screens/auth/login_screen.dart';

/// "Sair da conta" da criança: ÚNICO ponto de saída (menu lateral e Perfil).
///
/// Mesmo comportamento que o Perfil já tinha: pergunta, encerra a sessão,
/// limpa o usuário da biometria e volta ao login. Além disso, zera a cor do
/// tema e o perfil da criança, para a próxima criança que entrar neste
/// aparelho não ver a cor nem o nome da anterior.
///
/// [context] precisa estar abaixo de um `Navigator` e de um
/// `ScaffoldMessenger`. Vindo do menu lateral, use o contexto da casca
/// (`ChildShellScope.afterDrawerClosed`), porque o do menu some ao fechar.
Future<void> sairDaContaCrianca(BuildContext context) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        'Sair da conta?',
        style: LummyFonts.body(fontWeight: FontWeight.w600),
      ),
      content: Text(
        'Tem certeza que deseja sair? Você precisará fazer login novamente.',
        style: LummyFonts.body(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'Cancelar',
            style: LummyFonts.body(
              color: Theme.of(dialogContext).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            'Sair',
            style: LummyFonts.body(
              color: LummyColors.red500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmou != true || !context.mounted) return;

  // Tudo que depende do contexto é lido antes dos awaits.
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final corDoTema = context.read<ChildThemeColorController>();
  final perfil = context.read<ChildProfileController>();
  final temaDoApp = context.read<ThemeProvider>();

  try {
    await locator<AuthRepository>().logout();
    await locator<BiometricAuthService>().clearCachedUser();
  } catch (e) {
    appLog('❌ Erro ao sair da conta: $e');
    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Não foi possível sair. Tente de novo.',
          style: LummyFonts.body(),
        ),
        backgroundColor: LummyColors.red500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    return;
  }

  void zerarCrianca() {
    corDoTema.reset();
    perfil.reset();
  }

  if (!navigator.mounted) {
    zerarCrianca();
    return;
  }

  temaDoApp.setPreLoginLightOnly(true);
  final rotaLogin = MaterialPageRoute<void>(builder: (_) => const LoginScreen());
  navigator.pushAndRemoveUntil(rotaLogin, (route) => false);

  // A área da criança ainda aparece por baixo enquanto o login entra. Zerar só
  // quando a transição termina evita a cor e o avatar trocarem à vista.
  final entrada = rotaLogin.animation;
  if (entrada == null || entrada.isCompleted) {
    zerarCrianca();
    return;
  }
  late final AnimationStatusListener aoTerminar;
  aoTerminar = (status) {
    if (status != AnimationStatus.completed) return;
    entrada.removeStatusListener(aoTerminar);
    zerarCrianca();
  };
  entrada.addStatusListener(aoTerminar);
}
