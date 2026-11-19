import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Diálogo "Recuperar senha". O envio (Supabase) fica na tela, via onSubmit.
/// Cancelar fecha retornando false.
class LoginForgotPasswordDialog extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final Future<void> Function() onSubmit;

  const LoginForgotPasswordDialog({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? LummyColors.slate800
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: LummyColors.brandBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_reset_rounded, color: LummyColors.brandBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Recuperar senha',
              style: LummyFonts.body(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : LummyColors.slate800,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digite seu e-mail e enviaremos um link para redefinir sua senha.',
              style: LummyFonts.body(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? LummyColors.slate400
                    : LummyColors.slate500,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: LummyFonts.body(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: 'Seu e-mail',
                hintStyle: LummyFonts.body(fontSize: 14),
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Insira seu e-mail';
                }
                if (!RegExp(r'^[\w-\.]+@[\w-]+\.[\w-]{2,4}$').hasMatch(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: LummyFonts.body(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? LummyColors.slate400
                  : LummyColors.slate500,
            ),
          ),
        ),
        FilledButton(
          onPressed: onSubmit,
          style: FilledButton.styleFrom(
            backgroundColor: LummyColors.brandBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('Enviar', style: LummyFonts.body(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
