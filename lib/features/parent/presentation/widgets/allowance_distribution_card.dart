import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../application/app_facade.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../di/locator.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../shared/widgets/lummy_feedback.dart';

class AllowanceDistributionCard extends StatefulWidget {
  final double availableBalance;
  final List<ChildEntity> children;
  final Future<bool> Function(double amount) onDistributeEqually;
  final Future<bool> Function(String childId, double amount) onDepositToChild;

  const AllowanceDistributionCard({
    super.key,
    required this.availableBalance,
    required this.children,
    required this.onDistributeEqually,
    required this.onDepositToChild,
  });

  @override
  State<AllowanceDistributionCard> createState() =>
      _AllowanceDistributionCardState();
}

class _AllowanceDistributionCardState extends State<AllowanceDistributionCard> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;

  // Cores consistentes com o app
  static const _orange = Color(0xFFF59E0B);
  static const _amber = Color(0xFFD97706);
  static const _green = Color(0xFF10B981);
  static const _blue = Color(0xFF3B82F6);
  static const _purple = Color(0xFF8B5CF6);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF334155), Color(0xFF1E293B)]
              : [Colors.white, _orange.withOpacity(0.03)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : _orange.withOpacity(0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : _orange.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_orange, _amber]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribuir Recursos',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      widget.children.length > 1
                          ? 'Envie para todos ou individualmente'
                          : 'Distribuição igual requer 2+ filhos',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Saldo badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _orange.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _orange.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Disponível: ',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(widget.availableBalance),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Campo de valor
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF475569)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
              ],
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'Digite o valor (Ex: 150,00)',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(
                  Icons.attach_money_rounded,
                  color: _orange,
                  size: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Botões de ação
          Row(
            children: [
              // Botão Distribuir Igualmente
              Expanded(
                child: _buildActionButton(
                  label: 'Distribuir Igualmente',
                  icon: Icons.group_rounded,
                  gradient: const [_orange, _amber],
                  onPressed: _canSubmit
                      && widget.children.length > 1
                      ? () async {
                          final amount = _parseAmount();
                          if (amount == null || amount <= 0) return;
                          if (amount > widget.availableBalance) {
                            LummyFeedback.warning(
                              context,
                              'Valor ultrapassa o saldo disponível',
                            );
                            return;
                          }
                          final bio = locator<BiometricAuthService>();
                          final auth =
                              await bio.authenticateSensitiveAction(
                            reason:
                                'Confirme para distribuir ${AppFormatters.formatCurrency(amount)}',
                          );
                          if (!auth || !mounted) return;
                          setState(() => _isProcessing = true);
                          final ctx = context;
                          final ok =
                              await widget.onDistributeEqually(amount);
                          if (!mounted) return;
                          setState(() {
                            _isProcessing = false;
                            if (ok) _amountController.clear();
                          });
                          if (ok) {
                            LummyFeedback.success(
                              ctx,
                              'Distribuição realizada com sucesso!',
                            );
                          } else {
                            LummyFeedback.error(
                              ctx,
                              'Erro ao distribuir. Tente novamente.',
                            );
                          }
                        }
                      : null,
                  isLoading: _isProcessing,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 14),
              // Botão Depósito Individual
              Expanded(
                child: _buildActionButton(
                  label: 'Individual',
                  icon: Icons.person_rounded,
                  gradient: const [_blue, _purple],
                  onPressed: widget.children.isEmpty
                      ? null
                      : () async {
                          await _openIndividualDepositModal(context, isDark);
                        },
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback? onPressed,
    bool isLoading = false,
    required bool isDark,
  }) {
    final isEnabled = onPressed != null && !isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(colors: gradient)
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isEnabled
                          ? Colors.white
                          : (isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8)),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isEnabled
                              ? Colors.white
                              : (isDark
                                    ? const Color(0xFF64748B)
                                    : const Color(0xFF94A3B8)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  bool get _canSubmit =>
      !_isProcessing && (_parseAmount() ?? 0) > 0 && widget.children.isNotEmpty;

  double? _parseAmount() {
    final raw = _amountController.text.trim();
    if (raw.isEmpty) return null;
    final sanitized = raw
        .replaceAll('.', '')
        .replaceAll(' ', '')
        .replaceAll('R\$', '')
        .replaceAll('\$', '')
        .replaceAll(',', '.');

    final value = double.tryParse(sanitized);
    if (value == null) return null;
    return double.parse(value.toStringAsFixed(2));
  }

  Future<void> _openIndividualDepositModal(
    BuildContext context,
    bool isDark,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? selectedChildId = widget.children.isNotEmpty
        ? widget.children.first.id
        : null;
    final TextEditingController amountController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF334155), Color(0xFF1E293B)]
                  : const [Colors.white, Color(0xFFFFFBF5)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF475569)
                  : const Color(0xFFF1F5F9),
            ),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_blue, _purple],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Depósito Individual',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedChildId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.child_care_rounded,
                        color: _purple,
                        size: 18,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    dropdownColor: isDark
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    items: widget.children
                        .map(
                          (child) => DropdownMenuItem(
                            value: child.id,
                            child: Text(child.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      selectedChildId = value;
                    },
                    validator: (value) =>
                        value == null ? 'Selecione uma criança' : null,
                  ),
                ),
                const SizedBox(height: 16),
                // Valor
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                    ],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ex.: 50,00',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.attach_money_rounded,
                        color: _green,
                        size: 18,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    validator: (value) {
                      final sanitized =
                          value?.replaceAll('.', '').replaceAll(',', '.') ?? '';
                      final parsed = double.tryParse(sanitized);
                      if (parsed == null || parsed <= 0) {
                        return 'Informe um valor válido';
                      }
                      if (parsed > widget.availableBalance) {
                        return 'Saldo insuficiente';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 26),
                // Botão confirmar
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_green, Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _green.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        final sanitized = amountController.text
                            .replaceAll('.', '')
                            .replaceAll(',', '.');
                        final parsed = double.tryParse(sanitized);
                        if (parsed != null && selectedChildId != null) {
                          final bio = locator<BiometricAuthService>();
                          final auth =
                              await bio.authenticateSensitiveAction(
                            reason: 'Confirme para depositar',
                          );
                          if (!auth) return;
                          final ok = await widget.onDepositToChild(
                            selectedChildId!,
                            double.parse(parsed.toStringAsFixed(2)),
                          );
                          if (bottomSheetContext.mounted) {
                            Navigator.of(bottomSheetContext).pop(ok);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Confirmar Depósito',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    final ctx = context;
    if (result == true) {
      LummyFeedback.success(ctx, 'Depósito realizado com sucesso!');
    } else if (result == false) {
      LummyFeedback.error(ctx, 'Erro ao depositar. Tente novamente.');
    }
  }

}
