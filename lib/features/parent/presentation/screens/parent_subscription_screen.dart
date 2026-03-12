import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentSubscriptionScreen extends StatefulWidget {
  const ParentSubscriptionScreen({super.key});

  @override
  State<ParentSubscriptionScreen> createState() => _ParentSubscriptionScreenState();
}

class _ParentSubscriptionScreenState extends State<ParentSubscriptionScreen> {
  int _childrenCount = 2;

  double get _forYouPrice => 19.9 + (_childrenCount * 9.9);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Escolha o plano ideal para sua família',
            style: GoogleFonts.poppins(
              color: subtitleColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 12),
          _PlanCard(
            title: 'Lummy For You',
            subtitle: 'Você paga conforme a quantidade de filhos',
            badge: 'Personalizável',
            priceLabel: 'R\$ ${_forYouPrice.toStringAsFixed(2).replaceAll('.', ',')}/mês',
            features: const [
              'Preço proporcional ao número de filhos',
              'Ideal para famílias menores',
              'Mesmo controle financeiro por filho',
            ],
            gradient: const [Color(0xFFF59E0B), Color(0xFFFB7185)],
            isDark: isDark,
            footer: _buildChildrenSelector(isDark, titleColor, subtitleColor),
          ),
          const SizedBox(height: 14),
          Text(
            'Dica: com muitos filhos, o LummyPro tende a compensar mais.',
            style: GoogleFonts.poppins(
              color: subtitleColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSelector(bool isDark, Color titleColor, Color subtitleColor) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
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
          Slider(
            value: _childrenCount.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_childrenCount',
            activeColor: const Color(0xFFF59E0B),
            onChanged: (value) {
              setState(() => _childrenCount = value.round());
            },
          ),
          Text(
            'Base de R\$ 19,90 + R\$ 9,90 por filho.',
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
      padding: const EdgeInsets.all(16),
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
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gradient.first.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            priceLabel,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
