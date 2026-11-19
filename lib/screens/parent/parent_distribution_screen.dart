import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class ParentDistributionScreen extends StatefulWidget {
  const ParentDistributionScreen({super.key});

  @override
  State<ParentDistributionScreen> createState() =>
      _ParentDistributionScreenState();
}

class _ParentDistributionScreenState extends State<ParentDistributionScreen> {
  // Paleta de cores - laranja vibrante
  static const _orange = LummyColors.amber500;
  static const _amber = LummyColors.amber600;
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
                SliverToBoxAdapter(child: _buildHeader(context, state, isDark)),
                // Conteúdo
                if (state.children.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _orange.withValues(alpha: 0.15),
                                    _amber.withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                size: 64,
                                color: _orange,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Sem filhos cadastrados',
                              style: LummyFonts.body(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : LummyColors.slate800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cadastre pelo menos um filho para poder enviar dinheiro.',
                              textAlign: TextAlign.center,
                              style: LummyFonts.body(
                                fontSize: 14,
                                color: isDark
                                    ? LummyColors.slate400
                                    : LummyColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildScanQRSection(context, state, isDark),
                        const SizedBox(height: 20),
                        _buildQuickSendSection(context, state, isDark),
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

  Widget _buildHeader(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [LummyColors.yellow950, LummyColors.amber900, LummyColors.amber800]
              : const [LummyColors.amber500, LummyColors.amber600, LummyColors.amber700],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: isDark ? 0.2 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enviar Dinheiro',
                      style: LummyFonts.body(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Distribua recursos para seus filhos',
                      style: LummyFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Saldo disponível
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Saldo Disponível para Envio',
                      style: LummyFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppFormatters.formatCurrency(state.walletBalance),
                    style: LummyFonts.body(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanQRSection(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [LummyColors.slate800, LummyColors.indigo900]
              : [_blue.withValues(alpha: 0.1), _purple.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? _purple.withValues(alpha: 0.3) : _blue.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_blue, _purple]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanear QR Code',
                      style: LummyFonts.body(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : LummyColors.slate800,
                      ),
                    ),
                    Text(
                      'Seu filho pediu dinheiro? Escaneie!',
                      style: LummyFonts.body(
                        fontSize: 13,
                        color: isDark
                            ? LummyColors.slate400
                            : LummyColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Botões de ação
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openQRScanner(context, state),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_blue, _purple],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _blue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Escanear',
                            style: LummyFonts.body(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showCodeInputDialog(context, state),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : _purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _purple.withValues(alpha: isDark ? 0.3 : 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.keyboard_rounded,
                            color: _purple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Digitar código',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: LummyFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _purple,
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
          ),
        ],
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
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
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
                    onTap: () {
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

  Widget _buildQuickSendSection(
    BuildContext context,
    ParentDashboardState state,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [LummyColors.slate700, LummyColors.slate800]
              : const [Colors.white, LummyColors.cream],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? LummyColors.slate600 : _orange.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.24)
                : _orange.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_orange, _amber]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
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
                    'Envio Rápido',
                    style: LummyFonts.body(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : LummyColors.slate800,
                    ),
                  ),
                  Text(
                    'Selecione um valor pré-definido',
                    style: LummyFonts.body(
                      fontSize: 13.5,
                      color: isDark
                          ? LummyColors.slate400
                          : LummyColors.slate500,
                    ),
                  ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Quick amount buttons - Design moderno
          Row(
            children: [
              Expanded(
                child: _buildQuickAmountChip(
                  context,
                  state,
                  10.0,
                  _orange,
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAmountChip(
                  context,
                  state,
                  20.0,
                  _amber,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAmountChip(
                  context,
                  state,
                  50.0,
                  _blue,
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildQuickAmountChip(
                  context,
                  state,
                  100.0,
                  _purple,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChip(
    BuildContext context,
    ParentDashboardState state,
    double amount,
    Color color,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _beginQuickSendWithAuth(context, state, amount),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: isDark ? 0.2 : 0.12),
                color.withValues(alpha: isDark ? 0.1 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppFormatters.formatCurrency(amount),
                style: LummyFonts.body(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enviar',
                style: LummyFonts.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? LummyColors.slate400
                      : LummyColors.slate500,
                ),
              ),
            ],
          ),
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
