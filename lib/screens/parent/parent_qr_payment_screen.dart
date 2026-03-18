import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lummy_login/core/utils/formatters.dart';
import 'package:lummy_login/features/parent/presentation/bloc/parent_dashboard_cubit.dart';

/// Confirmação de envio ao filho após leitura do QR Code — identidade visual Lummy.
class ParentQRPaymentScreen extends StatefulWidget {
  final String childId;
  final double amount;
  final String? requestTransactionId;

  const ParentQRPaymentScreen({
    super.key,
    required this.childId,
    required this.amount,
    this.requestTransactionId,
  });

  @override
  State<ParentQRPaymentScreen> createState() => _ParentQRPaymentScreenState();
}

class _ParentQRPaymentScreenState extends State<ParentQRPaymentScreen> {
  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF3B82F6);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _orange = Color(0xFFF59E0B);

  bool _isLoading = true;
  bool _isSending = false;
  String? _childName;
  String? _description;
  String? _error;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isAuthorized = false;
    });

    if (kDebugMode) {
      debugPrint(
        '📱 [QR Payment] Carregando: childId=${widget.childId}, amount=${widget.amount}, requestId=${widget.requestTransactionId}',
      );
    }

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) debugPrint('📱 [QR Payment] Usuário não logado');
        setState(() {
          _isLoading = false;
          _error = 'Faça login para continuar';
        });
        return;
      }

      if (kDebugMode) debugPrint('📱 [QR Payment] currentUser.id=${currentUser.id}');

      final childRow = await supabase
          .from('children')
          .select('id, nome, responsavel_id')
          .eq('id', widget.childId)
          .maybeSingle();

      if (childRow == null) {
        if (kDebugMode) {
          debugPrint('📱 [QR Payment] Filho não encontrado para childId=${widget.childId}');
        }
        setState(() {
          _isLoading = false;
          _error =
              'Filho não encontrado. Verifique se o código foi gerado pelo app do filho.';
        });
        return;
      }

      final responsavelId = childRow['responsavel_id'] as String?;
      final responsavelIdTrimmed = responsavelId?.trim();
      final currentUserId = currentUser.id.trim();
      if (kDebugMode) {
        debugPrint(
          '📱 [QR Payment] responsavel_id=$responsavelIdTrimmed | currentUser.id=$currentUserId | match=${responsavelIdTrimmed == currentUserId}',
        );
      }
      if (responsavelIdTrimmed != currentUserId) {
        setState(() {
          _isLoading = false;
          _childName = childRow['nome'] as String?;
          _isAuthorized = false;
          _error = 'Apenas o responsável pode enviar este valor para ${_childName ?? "o filho"}. '
              'Verifique se está logado com a conta do responsável deste filho.';
        });
        return;
      }

      String? description;
      if (widget.requestTransactionId != null &&
          widget.requestTransactionId!.isNotEmpty) {
        final txRow = await supabase
            .from('transactions')
            .select('description')
            .eq('id', widget.requestTransactionId!)
            .maybeSingle();
        description = txRow?['description'] as String?;
      }

      if (mounted) {
        setState(() {
          _childName = childRow['nome'] as String?;
          _description = description?.trim();
          _isAuthorized = true;
          _isLoading = false;
        });
      }
      if (kDebugMode) debugPrint('📱 [QR Payment] OK: autorizado para $_childName');
    } catch (e, st) {
      if (kDebugMode) debugPrint('📱 [QR Payment] Erro: $e\n$st');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isAuthorized = false;
          _error = 'Erro ao carregar dados. Tente novamente.';
        });
      }
    }
  }

  Future<void> _confirmAndSend() async {
    if (!_isAuthorized || _childName == null) return;

    setState(() => _isSending = true);

    try {
      final cubit = context.read<ParentDashboardCubit>();
      bool ok = false;
      if (widget.requestTransactionId != null &&
          widget.requestTransactionId!.isNotEmpty) {
        ok = await cubit.approveTransaction(widget.requestTransactionId!);
      } else {
        ok = await cubit.transferToChild(
          widget.childId,
          widget.amount,
          description: _description,
        );
      }

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppFormatters.formatCurrency(widget.amount)} enviado para $_childName!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isSending = false);
        final message = cubit.state.error ?? 'Erro ao enviar. Tente novamente.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: GoogleFonts.poppins()),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao enviar. Tente novamente.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    Widget body;
    if (_isLoading) {
      body = _buildLoadingState(isDark, textSecondary);
    } else if (_error != null && !_isAuthorized) {
      body = _buildErrorState(
        context,
        isDark,
        textSecondary,
        cardBg,
        borderColor,
      );
    } else if (_isAuthorized) {
      body = _buildPaymentContent(
        context,
        isDark,
        cardBg,
        borderColor,
        textSecondary,
      );
    } else {
      body = _buildErrorState(
        context,
        isDark,
        textSecondary,
        cardBg,
        borderColor,
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: body),
    );
  }

  Widget _buildLoadingState(bool isDark, Color textSecondary) {
    return Column(
      children: [
        _buildHeaderGradient(isDark, showBack: true),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _purple.withValues(alpha: 0.2),
                        _blue.withValues(alpha: 0.15),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      color: _purple,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Validando pedido',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conectando com sua conta Lummy…',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    Color textSecondary,
    Color cardBg,
    Color borderColor,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeaderGradient(isDark, showBack: true)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _red.withValues(alpha: 0.15),
                          _orange.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security_rounded,
                      size: 48,
                      color: isDark ? _red.withValues(alpha: 0.9) : _red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _error ?? 'Não foi possível carregar. Tente novamente.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Voltar',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentContent(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textSecondary,
  ) {
    final name = _childName ?? '—';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeaderGradient(isDark, showBack: true)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: isDark ? 36 : 44),
              // Valor em destaque
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF2E1065),
                            const Color(0xFF1E1B4B),
                          ]
                        : [
                            const Color(0xFFF5F3FF),
                            const Color(0xFFEEF2FF),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? _purple.withValues(alpha: 0.35)
                        : _purple.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: isDark ? 0.2 : 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 20,
                          color: isDark
                              ? _purple.withValues(alpha: 0.9)
                              : _purple,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pedido via QR Code',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFC4B5FD)
                                : _purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Valor a enviar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFA5B4FC)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppFormatters.formatCurrency(widget.amount),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                        letterSpacing: -1.2,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Direto ao filho · via QR Code',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: textSecondary.withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Beneficiário
              _buildSectionLabel('Beneficiário', textSecondary),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_blue, _purple],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _blue.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Filho cadastrado na sua conta Lummy',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionLabel('Descrição', textSecondary),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notes_rounded,
                        size: 22,
                        color: _blue,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (_description != null && _description!.isNotEmpty)
                                ? _description!
                                : 'Sem descrição no QR',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              height: 1.45,
                            ),
                          ),
                          if (_description == null || _description!.isEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              'O filho pode incluir um motivo ao gerar o código no futuro.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Brand strip
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      _purple.withValues(alpha: 0.08),
                      _blue.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: _purple.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_blue, _purple],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.family_restroom_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lummy',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Educação financeira em família',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [_purple, Color(0xFF7C3AED)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isSending ? null : _confirmAndSend,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _isSending
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Confirmar e enviar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'O valor será debitado do seu saldo Lummy e creditado no saldo do filho.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderGradient(bool isDark, {required bool showBack}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF2E1065),
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                ]
              : const [
                  Color(0xFF8B5CF6),
                  Color(0xFF7C3AED),
                  Color(0xFF6366F1),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.25 : 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
              if (showBack) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enviar dinheiro',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pedido escaneado pelo QR Code',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, Color textSecondary) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}
