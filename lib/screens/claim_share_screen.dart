import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClaimShareScreen extends StatefulWidget {
  final double totalAmount;
  final double currentChildScore;
  final List<double> otherChildrenScores;
  final List<String>? otherChildrenNames;
  final String? currentChildName;

  const ClaimShareScreen({
    super.key,
    required this.totalAmount,
    required this.currentChildScore,
    required this.otherChildrenScores,
    this.otherChildrenNames,
    this.currentChildName,
  });

  @override
  State<ClaimShareScreen> createState() => _ClaimShareScreenState();
}

class _ClaimShareScreenState extends State<ClaimShareScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _claimed = false;
  bool _alreadyClaimed = false; // temporariamente ignorado para testes

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _fadeController.forward();
    _slideController.forward();
    _loadClaimed();
  }

  Future<void> _loadClaimed() async {
    // Temporariamente permitir múltiplos resgates para testes
    setState(() {
      _alreadyClaimed = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  double _computeYourShare() {
    final scores = [widget.currentChildScore, ...widget.otherChildrenScores];
    final totalScore = scores.fold<double>(0, (a, b) => a + (b < 0 ? 0 : b));
    if (totalScore <= 0) return 0;
    final ratio =
        (widget.currentChildScore <= 0 ? 0 : widget.currentChildScore) /
        totalScore;
    final cents = (widget.totalAmount * 100).round();
    final yourCents = (cents * ratio).floor();
    return yourCents / 100.0;
  }

  List<Map<String, dynamic>> _buildParticipantsBreakdown() {
    final all = [
      {
        'name': widget.currentChildName ?? 'Você',
        'score': widget.currentChildScore,
        'isCurrent': true,
      },
      ...widget.otherChildrenScores.asMap().entries.map(
        (e) => {
          'name':
              widget.otherChildrenNames != null &&
                  e.key < widget.otherChildrenNames!.length
              ? widget.otherChildrenNames![e.key]
              : 'Irmão(a) ${e.key + 1}',
          'score': e.value,
          'isCurrent': false,
        },
      ),
    ];
    final totalScore = all.fold<double>(
      0,
      (a, b) => a + (b['score'] as double),
    );
    return all.map((p) {
      final s = (p['score'] as double);
      final ratio = totalScore > 0
          ? (s.clamp(0, double.infinity)) / totalScore
          : 0.0;
      final amount = (widget.totalAmount * ratio);
      return {...p, 'ratio': ratio, 'amount': (amount * 100).floor() / 100.0};
    }).toList();
  }

  void _claim() {
    final amount = _computeYourShare();
    setState(() => _claimed = true);
    _persistClaimed();
    Navigator.pop(context, {'claimed': true, 'amount': amount});
  }

  Future<void> _persistClaimed() async {
    // Temporariamente não persistir flag de resgate
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmall = MediaQuery.of(context).size.height < 700;
    final yourShare = _computeYourShare();
    final breakdown = _buildParticipantsBreakdown();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(isSmall ? 16.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmall ? 8 : 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? theme.dividerColor
                                  : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: theme.textTheme.bodyLarge?.color,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resgatar',
                              style: GoogleFonts.poppins(
                                fontSize: isSmall ? 22 : 24,
                                fontWeight: FontWeight.w700,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Valor definido pelo responsável',
                              style: GoogleFonts.poppins(
                                fontSize: isSmall ? 14 : 16,
                                fontWeight: FontWeight.w400,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  if (_alreadyClaimed) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Você já resgatou sua parte',
                              style: GoogleFonts.poppins(
                                fontSize: isSmall ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Card com total disponível
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmall ? 20.0 : 24.0),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? theme.dividerColor
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.savings_rounded,
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
                                'Valor em disputa',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'R\$ ${widget.totalAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 22 : 26,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Breakdown proporcional
                  Text(
                    'Como o valor é dividido',
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...breakdown.map((p) {
                    final color = (p['isCurrent'] as bool)
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF64748B);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? theme.dividerColor
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              (p['isCurrent'] as bool)
                                  ? Icons.star_rounded
                                  : Icons.person_rounded,
                              color: color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: theme.textTheme.titleMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Score: ${(p['score'] as double).toStringAsFixed(0)} • ${(100 * (p['ratio'] as double)).toStringAsFixed(0)}% do total',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'R\$ ${(p['amount'] as double).toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Sua parte
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmall ? 16.0 : 18.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sua parte estimada',
                          style: GoogleFonts.poppins(
                            fontSize: isSmall ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${yourShare.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: isSmall ? 26 : 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _claim,
                      icon: const Icon(Icons.payments_rounded, size: 22),
                      label: Text(
                        'Retirar minha parte',
                        style: GoogleFonts.poppins(
                          fontSize: isSmall ? 16 : 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmall ? 16 : 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
