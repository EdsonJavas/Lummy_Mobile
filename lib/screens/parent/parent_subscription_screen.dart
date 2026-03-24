import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lummy_login/core/constants/app_constants.dart';

class ParentSubscriptionScreen extends StatefulWidget {
  const ParentSubscriptionScreen({super.key});

  @override
  State<ParentSubscriptionScreen> createState() => _ParentSubscriptionScreenState();
}

class _ParentSubscriptionScreenState extends State<ParentSubscriptionScreen> {
  int _childrenCount = 2;

  double get _forYouPrice => 19.9 + (_childrenCount * 9.9);

  List<String> get _lummyForYouFeatures => [
        'Até ${AppConstants.lummyForYouMaxChildren} filhos no plano',
        'Preço proporcional ao número de filhos',
        'Mesmo controle financeiro por filho',
      ];

  static String _formatPrice(double value) {
    final s = value.toStringAsFixed(2);
    return 'R\$ ${s.replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Assinatura',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _buildCurrentPlanBanner(isDark, titleColor, subtitleColor),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Escolha o plano ideal para sua família',
                  style: GoogleFonts.poppins(
                    color: titleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Altere quando quiser. Cancele sem multa.',
            style: GoogleFonts.poppins(
              color: subtitleColor,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          _PlanCard(
            title: 'LummyPro',
            subtitle: 'Plano completo para famílias grandes',
            badge: 'Mais vantajoso para muitos filhos',
            priceLabel: 'R\$ 129,90/mês',
            features: const [
              'Filhos ilimitados',
              'Todas as funcionalidades de controle',
              'Missões, aprovações e gestão completa',
            ],
            gradient: const [Color(0xFF7C3AED), Color(0xFF3B82F6)],
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _PlanCard(
            title: 'Lummy For You',
            subtitle: 'Você paga conforme a quantidade de filhos',
            badge: 'Seu plano atual',
            priceLabel: '${_formatPrice(_forYouPrice)}/mês',
            features: _lummyForYouFeatures,
            gradient: const [Color(0xFFF59E0B), Color(0xFFFB7185)],
            isDark: isDark,
            footer: _buildChildrenSelector(isDark, titleColor, subtitleColor),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lummy For You inclui até ${AppConstants.lummyForYouMaxChildren} filhos. Do 4º em diante, o Lummy Pro é o plano certo.',
                    style: GoogleFonts.poppins(
                      color: subtitleColor,
                      fontSize: 12,
                      height: 1.4,
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

  Widget _buildCurrentPlanBanner(bool isDark, Color titleColor, Color subtitleColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.12),
            const Color(0xFFFB7185).withValues(alpha: isDark ? 0.12 : 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seu plano atual',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lummy For You · ${_formatPrice(_forYouPrice)}/mês',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSelector(bool isDark, Color titleColor, Color subtitleColor) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantidade de filhos: $_childrenCount',
            style: GoogleFonts.poppins(
              color: titleColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF59E0B),
              inactiveTrackColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              thumbColor: const Color(0xFFF59E0B),
            ),
            child: Slider(
              value: _childrenCount.toDouble(),
              min: 1,
              max: AppConstants.lummyForYouMaxChildren.toDouble(),
              divisions: AppConstants.lummyForYouMaxChildren - 1,
              label: '$_childrenCount',
              onChanged: (value) {
                setState(() => _childrenCount = value.round());
              },
            ),
          ),
          Text(
            'Plano For You: no máximo ${AppConstants.lummyForYouMaxChildren} filhos. Base R\$ 19,90 + R\$ 9,90 por filho.',
            style: GoogleFonts.poppins(
              color: subtitleColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final String priceLabel;
  final List<String> features;
  final List<Color> gradient;
  final bool isDark;
  final Widget? footer;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.priceLabel,
    required this.features,
    required this.gradient,
    required this.isDark,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.first.withValues(alpha: isDark ? 0.22 : 0.14),
            gradient.last.withValues(alpha: isDark ? 0.16 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gradient.first.withValues(alpha: isDark ? 0.4 : 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: gradient.first.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              priceLabel,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 14),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.35,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ?footer,
        ],
      ),
    );
  }
}
