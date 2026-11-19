import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:lummy/application/app_facade.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/di/locator.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/features/parent/presentation/widgets/allowance_distribution_card.dart';
import 'package:lummy/features/parent/presentation/widgets/parent_dashboard_skeleton.dart';
import 'package:lummy/screens/parent/parent_qr_payment_screen.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/distribution/distribution_code_input_sheet.dart';
import 'package:lummy/screens/parent/widgets/distribution/distribution_empty_state.dart';
import 'package:lummy/screens/parent/widgets/distribution/distribution_header.dart';
import 'package:lummy/screens/parent/widgets/distribution/distribution_quick_send_section.dart';
import 'package:lummy/screens/parent/widgets/distribution/distribution_scan_qr_section.dart';

class ParentDistributionScreen extends StatefulWidget {
  const ParentDistributionScreen({super.key});

  @override
  State<ParentDistributionScreen> createState() =>
      _ParentDistributionScreenState();
}

class _ParentDistributionScreenState extends State<ParentDistributionScreen> {
  // Paleta de cores - laranja vibrante
  static const _orange = LummyColors.amber500;
  static const _blue = LummyColors.blue500;
  static const _purple = LummyColors.violet500;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? LummyColors.darkMaterial
          : LummyColors.slate50,
      body: BrandedRefreshIndicator(
        onRefresh: () => context.read<ParentDashboardCubit>().refresh(),
        color: _orange,
        child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.children.isEmpty) {
              return const ParentDashboardSkeleton();
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header com gradiente
                SliverToBoxAdapter(
                  child: DistributionHeader(
                    isDark: isDark,
                    walletBalance: state.walletBalance,
                  ),
                ),
                // Conteúdo
                if (state.children.isEmpty)
                  SliverFillRemaining(
                    child: DistributionEmptyState(isDark: isDark),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        DistributionScanQrSection(
                          isDark: isDark,
                          onScan: () => _openQRScanner(context, state),
                          onTypeCode: () => _showCodeInputDialog(context, state),
                        ),
                        const SizedBox(height: 20),
                        DistributionQuickSendSection(
                          isDark: isDark,
                          onQuickSend: (amount) =>
                              _beginQuickSendWithAuth(context, state, amount),
                        ),
                        const SizedBox(height: 20),
                        AllowanceDistributionCard(
                          availableBalance: state.walletBalance,
                          children: state.children,
                          onDistributeEqually: (amount) => context
                              .read<ParentDashboardCubit>()
                              .distributeAmount(amount),
                          onDepositToChild: (childId, amount) =>
                              context
                                  .read<ParentDashboardCubit>()
                                  .transferToChild(childId, amount),
                        ),
                      ]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openQRScanner(BuildContext context, ParentDashboardState state) {
    // Usar o contexto da tela (tem BlocProvider); o sheet usa outro contexto.
    final parentContext = context;
    final cubit = context.read<ParentDashboardCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? LummyColors.slate800 : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? LummyColors.slate500 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_blue, _purple]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
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
                          'Escanear QR Code',
                          style: LummyFonts.body(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : LummyColors.slate800,
                          ),
                        ),
                        Text(
                          'Aponte a câmera para o QR Code',
                          style: LummyFonts.body(
                            fontSize: 13,
                            color: isDark
                                ? LummyColors.slate300
                                : LummyColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? LummyColors.slate300 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _purple.withValues(alpha: 0.3), width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        final code = barcode.rawValue!;
                        Navigator.pop(sheetContext);
                        if (!parentContext.mounted) return;
                        _processQRCodeWithCubit(parentContext, code, state, cubit);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Text(
                'Posicione o QR Code dentro da área de leitura',
                textAlign: TextAlign.center,
                style: LummyFonts.body(
                  fontSize: 14,
                  color: isDark
                      ? LummyColors.slate400
                      : LummyColors.slate500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCodeInputDialog(BuildContext context, ParentDashboardState state) {
    final parentContext = context;
    final cubit = context.read<ParentDashboardCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DistributionCodeInputSheet(
        isDark: isDark,
        controller: controller,
        onSubmit: () {
          if (controller.text.isNotEmpty) {
            Navigator.pop(sheetContext);
            if (!parentContext.mounted) return;
            _processQRCodeWithCubit(
              parentContext,
              controller.text,
              state,
              cubit,
            );
          }
        },
      ),
    );
  }

  void _processQRCodeWithCubit(
    BuildContext context,
    String code,
    ParentDashboardState state,
    ParentDashboardCubit cubit,
  ) {
    // LUMMYREQ-{childId UUID}-{amount}-{requestId UUID} | LUMMY-{childId UUID}-{amount}
    try {
      final codeTrimmed = code.trim();
      if (codeTrimmed.isEmpty) {
        _showQRInvalidSnackBar(context);
        return;
      }

      double? amount;
      String? childId;
      String? requestTransactionId;

      bool isReasonableAmount(double? v) =>
          v != null && v > 0 && v <= 999999.99;

      int findAmountIndex(List<String> parts) {
        for (int i = 0; i < parts.length; i++) {
          if (parts[i].contains('.') && isReasonableAmount(double.tryParse(parts[i]))) {
            return i;
          }
        }
        for (int i = 0; i < parts.length; i++) {
          if (isReasonableAmount(double.tryParse(parts[i]))) return i;
        }
        return -1;
      }

      if (codeTrimmed.startsWith('LUMMYREQ-')) {
        final rest = codeTrimmed.substring('LUMMYREQ-'.length);
        final parts = rest.split('-');
        final amountIndex = findAmountIndex(parts);
        if (amountIndex != -1 && amountIndex > 0 && amountIndex < parts.length - 1) {
          childId = parts.sublist(0, amountIndex).join('-').trim();
          amount = double.tryParse(parts[amountIndex]);
          requestTransactionId = parts.sublist(amountIndex + 1).join('-').trim();
        }
      } else if (codeTrimmed.startsWith('LUMMY-')) {
        final rest = codeTrimmed.substring('LUMMY-'.length);
        final parts = rest.split('-');
        final amountIndex = findAmountIndex(parts);
        if (amountIndex != -1 && amountIndex > 0) {
          childId = parts.sublist(0, amountIndex).join('-').trim();
          amount = double.tryParse(parts[amountIndex]);
        }
      }

      final validAmount = amount;
      final validChildId = childId?.isNotEmpty == true ? childId : null;
      if (kDebugMode) {
        appLog('📱 [QR] Parse: childId=$validChildId, amount=$validAmount, requestId=$requestTransactionId');
      }
      if (validAmount != null && validAmount > 0 &&
          validChildId != null && validChildId.isNotEmpty) {
        if (!context.mounted) return;
        Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: ParentQRPaymentScreen(
                childId: validChildId,
                amount: validAmount,
                requestTransactionId: requestTransactionId,
              ),
            ),
          ),
        ).then((_) {
          if (context.mounted) cubit.refresh();
        });
      } else {
        _showQRInvalidSnackBar(context);
      }
    } catch (e, st) {
      appLog('❌ QR parse/process error: $e\n$st');
      _showQRInvalidSnackBar(context);
    }
  }

  void _showQRInvalidSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Código inválido. Use o QR Code gerado pelo app do filho.',
          style: LummyFonts.body(),
        ),
        backgroundColor: LummyColors.red500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _beginQuickSendWithAuth(
    BuildContext context,
    ParentDashboardState state,
    double amount,
  ) async {
    if (state.children.isEmpty) return;
    if (amount > state.walletBalance) {
      if (context.mounted) {
        LummyFeedback.warning(
          context,
          'Saldo insuficiente para envio rápido.',
        );
      }
      return;
    }

    final ok = await locator<BiometricAuthService>().authenticateSensitiveAction(
      reason:
          'Autentique para autorizar o envio rápido de ${AppFormatters.formatCurrency(amount)}.',
    );

    if (!context.mounted) return;
    if (ok) {
      await _openQuickSendDialog(context, state, amount);
    } else {
      LummyFeedback.error(
        context,
        'Não foi possível confirmar a identidade. Tente novamente.',
      );
    }
  }

  Future<void> _openQuickSendDialog(
    BuildContext context,
    ParentDashboardState state,
    double amount,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (state.children.isEmpty) return;
    if (amount > state.walletBalance) {
      if (context.mounted) {
        LummyFeedback.warning(
          context,
          'Saldo insuficiente para envio rápido.',
        );
      }
      return;
    }

    String selectedChildId = state.children.first.id;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? LummyColors.slate800 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Envio rápido ${AppFormatters.formatCurrency(amount)}',
                style: LummyFonts.body(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : LummyColors.slate800,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedChildId,
                items: state.children
                    .map(
                      (child) =>
                          DropdownMenuItem(value: child.id, child: Text(child.name)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedChildId = value;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Selecionar filho',
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('Enviar agora'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final cubit = context.read<ParentDashboardCubit>();
      await LummyFeedback.withLoading(
        context,
        action: () => cubit.transferToChild(selectedChildId, amount),
        successMessage:
            'Enviado ${AppFormatters.formatCurrency(amount)} com sucesso!',
        errorMessage: cubit.state.error ?? 'Erro ao enviar. Tente novamente.',
      );
    }
  }
}
