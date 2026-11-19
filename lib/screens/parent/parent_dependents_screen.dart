import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/domain/entities/user_entity.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/features/parent/presentation/widgets/parent_dashboard_skeleton.dart';
import 'package:lummy/screens/parent/child_control_panel_screen.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class ParentDependentsScreen extends StatelessWidget {
  const ParentDependentsScreen({super.key});

  // Paleta de cores vibrantes
  static const _purple = LummyColors.violet500;
  static const _blue = LummyColors.blue500;
  static const _pink = LummyColors.pink500;
  static const _green = LummyColors.emerald500;
  static const _orange = LummyColors.amber500;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? LummyColors.darkMaterial
          : LummyColors.slate50,
      body: BrandedRefreshIndicator(
        onRefresh: () => context.read<ParentDashboardCubit>().refresh(),
        color: _purple,
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
                // Lista de filhos ou estado vazio
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
                                    _purple.withValues(alpha: 0.15),
                                    _blue.withValues(alpha: 0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.family_restroom_rounded,
                                size: 64,
                                color: _purple,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Nenhum filho cadastrado',
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
                              'Adicione seu primeiro filho para começar a gerenciar as finanças da família.',
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final child = state.children[index];
                        final spending =
                            state.totalSpendingByChild[child.id] ?? 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildChildCard(
                            context,
                            child,
                            spending,
                            index,
                            isDark,
                          ),
                        );
                      }, childCount: state.children.length),
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
              ? const [LummyColors.violet950, LummyColors.purple950, LummyColors.purple900]
              : const [LummyColors.violet500, LummyColors.violet600, LummyColors.violet700],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: isDark ? 0.2 : 0.3),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.family_restroom_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meus Filhos',
                      style: LummyFonts.body(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${state.children.length} ${state.children.length == 1 ? 'cadastrado' : 'cadastrados'}',
                      style: LummyFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  'Saldo Total',
                  AppFormatters.formatCurrency(
                    state.children.fold<double>(0, (sum, c) => sum + c.balance),
                  ),
                  Icons.savings_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderStat(
                  'Gastos do Mês',
                  AppFormatters.formatCurrency(state.monthExpenseTotal),
                  Icons.receipt_long_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: LummyFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: LummyFonts.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(
    BuildContext context,
    ChildEntity child,
    double spending,
    int index,
    bool isDark,
  ) {
    // Cores alternadas para cada filho
    final colors = [_blue, _purple, _pink, _green, _orange];
    final cardColor = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildControlPanelScreen(child: child),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? LummyColors.darkMaterial : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? cardColor.withValues(alpha: 0.3)
                : cardColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: isDark ? 0.1 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar com gradiente
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cardColor, cardColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    child.gender == Gender.male
                        ? Icons.face_rounded
                        : Icons.face_3_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: LummyFonts.body(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : LummyColors.slate800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${child.age} anos',
                              style: LummyFonts.body(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: cardColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            size: 4,
                            color: isDark
                                ? LummyColors.slate500
                                : LummyColors.slate300,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            child.gender == Gender.male ? 'Menino' : 'Menina',
                            style: LummyFonts.body(
                              fontSize: 12,
                              color: isDark
                                  ? LummyColors.slate400
                                  : LummyColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Botão de ação
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: cardColor,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildChildStat(
                    'Saldo Atual',
                    AppFormatters.formatCurrency(child.balance),
                    _green,
                    Icons.account_balance_wallet_rounded,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChildStat(
                    'Gastos do Mês',
                    AppFormatters.formatCurrency(spending),
                    _orange,
                    Icons.shopping_bag_rounded,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildStat(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.2 : 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: LummyFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? LummyColors.slate400
                        : LummyColors.slate500,
                  ),
                ),
                Text(
                  value,
                  style: LummyFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
