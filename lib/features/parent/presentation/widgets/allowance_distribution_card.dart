import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../shared/widgets/widgets.dart';

class AllowanceDistributionCard extends StatefulWidget {
  final double availableBalance;
  final List<ChildEntity> children;
  final void Function(double amount) onDistributeEqually;
  final void Function(String childId, double amount) onDepositToChild;

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

class _AllowanceDistributionCardState
    extends State<AllowanceDistributionCard> {
  final TextEditingController _amountController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallScreen =
        MediaQuery.of(context).size.height < AppConstants.smallScreenHeight;

    return CustomCard(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Distribuir recursos',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  ),
                  child: Text(
                    'Disponível: ${AppFormatters.formatCurrency(widget.availableBalance)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            'Defina um valor para distribuir igualmente entre os filhos cadastrados ou faça depósitos individuais conforme necessário.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          CustomTextField(
            controller: _amountController,
            hintText: 'Ex.: 150,00',
            prefixIcon: Icons.attach_money_rounded,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Distribuir igualmente',
                  onPressed: _canSubmit
                      ? () async {
                          final amount = _parseAmount();
                          if (amount == null || amount <= 0) return;
                          if (amount > widget.availableBalance) {
                            _showLimitSnackBar(context);
                            return;
                          }
                          setState(() => _isProcessing = true);
                          await Future<void>.delayed(const Duration(milliseconds: 250));
                          widget.onDistributeEqually(amount);
                          setState(() {
                            _isProcessing = false;
                            _amountController.clear();
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Distribuição realizada com sucesso.',
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                        }
                      : null,
                  isLoading: _isProcessing,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              OutlinedButton.icon(
                onPressed: widget.children.isEmpty
                    ? null
                    : () async {
                        await _openIndividualDepositModal(context);
                      },
                icon: const Icon(Icons.payments_outlined),
                label: Text(
                  'Depósito individual',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 20,
                    vertical: isSmallScreen ? 14 : 16,
                  ),
                  side: BorderSide(color: colorScheme.primary.withOpacity(0.4)),
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
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

  Future<void> _openIndividualDepositModal(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String? selectedChildId =
        widget.children.isNotEmpty ? widget.children.first.id : null;
    final TextEditingController amountController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      builder: (bottomSheetContext) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            left: AppConstants.spacingLarge,
            right: AppConstants.spacingLarge,
            top: AppConstants.spacingLarge,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom +
                AppConstants.spacingLarge,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Depósito individual',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLarge),
                DropdownButtonFormField<String>(
                  initialValue: selectedChildId,
                  decoration: InputDecoration(
                    labelText: 'Selecione a criança',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                    ),
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
                const SizedBox(height: AppConstants.spacingLarge),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,\.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Valor',
                    hintText: 'Ex.: 50,00',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
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
                const SizedBox(height: AppConstants.spacingLarge),
                CustomButton(
                  text: 'Confirmar depósito',
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final sanitized = amountController.text
                          .replaceAll('.', '')
                          .replaceAll(',', '.');
                      final parsed = double.tryParse(sanitized);
                      if (parsed != null && selectedChildId != null) {
                        widget.onDepositToChild(
                          selectedChildId!,
                          double.parse(parsed.toStringAsFixed(2)),
                        );
                        Navigator.of(bottomSheetContext).pop(true);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Depósito realizado com sucesso.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _showLimitSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'O valor informado ultrapassa o saldo disponível.',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

