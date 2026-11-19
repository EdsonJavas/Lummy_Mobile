import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lummy/core/theme/design_tokens.dart';

/// Bottom sheet content to type / paste the code shared by the child.
///
/// The [controller] is owned by the caller; [onSubmit] is called when
/// "Processar código" is tapped.
class DistributionCodeInputSheet extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const DistributionCodeInputSheet({
    super.key,
    required this.isDark,
    required this.controller,
    required this.onSubmit,
  });

  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [LummyColors.slate700, LummyColors.slate800]
                : const [Colors.white, LummyColors.slate50],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border.all(
            color: isDark
                ? LummyColors.slate600
                : LummyColors.slate200,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? LummyColors.slate500 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_blue.withValues(alpha: 0.1), _purple.withValues(alpha: 0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_rounded,
                color: _purple,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Digite o código',
              style: LummyFonts.body(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : LummyColors.slate800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cole o código que seu filho compartilhou',
              textAlign: TextAlign.center,
              style: LummyFonts.body(
                fontSize: 14,
                color: isDark
                    ? LummyColors.slate400
                    : LummyColors.slate500,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              style: LummyFonts.body(
                fontSize: 16,
                color: isDark ? Colors.white : LummyColors.slate800,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: LUMMY-ABC123',
                hintStyle: LummyFonts.body(
                  color: isDark
                      ? LummyColors.slate400
                      : LummyColors.slate400,
                ),
                filled: true,
                fillColor: isDark
                    ? LummyColors.slate800
                    : LummyColors.slate100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark
                        ? LummyColors.slate600
                        : LummyColors.slate200,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _purple, width: 2),
                ),
                prefixIcon: Icon(
                  Icons.code_rounded,
                  color: isDark
                      ? LummyColors.slate400
                      : LummyColors.slate400,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 18,
                ),
                suffixIcon: IconButton(
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      controller.text = data!.text!;
                    }
                  },
                  icon: const Icon(Icons.paste_rounded, color: _purple),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSubmit,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_blue, _purple],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Processar código',
                        style: LummyFonts.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
