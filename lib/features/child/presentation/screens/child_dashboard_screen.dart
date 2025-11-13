import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/child_dashboard_cubit.dart';
import '../bloc/child_dashboard_state.dart';
import '../widgets/child_dashboard_skeleton.dart';

class ChildDashboardScreen extends StatelessWidget {
  final String userId;

  const ChildDashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChildDashboardCubit()..loadDashboard(userId),
      child: const _ChildDashboardView(),
    );
  }
}

class _ChildDashboardView extends StatelessWidget {
  const _ChildDashboardView();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < AppConstants.smallScreenHeight;

    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundLight),
      body: BlocBuilder<ChildDashboardCubit, ChildDashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const ChildDashboardSkeleton();
          }

          if (state.error != null) {
            return Center(
              child: EmptyState(
                emoji: '😔',
                title: 'Ops!',
                message: state.error!,
                buttonText: 'Tentar Novamente',
                onButtonPressed: () {
                  // Reload dashboard
                },
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(context, isSmallScreen),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildBalanceCard(context, state, isSmallScreen),
                  const SizedBox(height: AppConstants.spacingLarge),
                  if (state.currentGoal != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingLarge,
                      ),
                      child: GoalCard(
                        goal: state.currentGoal!,
                        onTap: () {
                          // Navegar para detalhes da meta
                        },
                      ),
                    ),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildQuickActions(context, isSmallScreen),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildRecentTransactions(context, state, isSmallScreen),
                  const SizedBox(height: AppConstants.spacingLarge),
                  _buildAchievements(context, state, isSmallScreen),
                  const SizedBox(height: AppConstants.spacingXLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Edson Jr',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(AppConstants.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Como estão suas finanças hoje?',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(AppConstants.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Navegar para perfil
            },
            child: Container(
              width: isSmallScreen ? 50 : 56,
              height: isSmallScreen ? 50 : 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(AppConstants.primaryBlue),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      AppConstants.primaryBlue,
                    ).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Color(AppConstants.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    ChildDashboardState state,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(AppConstants.primaryBlue),
            Color(AppConstants.primaryBlueDark),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: const Color(AppConstants.primaryBlue).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meu Cofrinho',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🐷',
                  style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppFormatters.formatCurrency(state.balance),
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 36 : 42,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (state.weeklyChange != 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (state.weeklyChange > 0
                            ? const Color(AppConstants.successGreen)
                            : const Color(AppConstants.errorRed))
                        .withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.weeklyChange > 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: state.weeklyChange > 0
                        ? const Color(AppConstants.successGreen)
                        : const Color(AppConstants.errorRed),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${state.weeklyChange > 0 ? '+' : ''}${AppFormatters.formatCurrency(state.weeklyChange)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: state.weeklyChange > 0
                          ? const Color(AppConstants.successGreen)
                          : const Color(AppConstants.errorRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'esta semana',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O que você quer fazer?',
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: const Color(AppConstants.textPrimary),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  onTap: () {
                    // Navegar para adicionar gasto
                  },
                  child: Column(
                    children: [
                      Container(
                        width: isSmallScreen ? 40 : 48,
                        height: isSmallScreen ? 40 : 48,
                        decoration: BoxDecoration(
                          color: const Color(
                            AppConstants.errorRed,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: Color(AppConstants.errorRed),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Registrar Gasto',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(AppConstants.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              Expanded(
                child: CustomCard(
                  onTap: () {
                    // Navegar para nova meta
                  },
                  child: Column(
                    children: [
                      Container(
                        width: isSmallScreen ? 40 : 48,
                        height: isSmallScreen ? 40 : 48,
                        decoration: BoxDecoration(
                          color: const Color(
                            AppConstants.purple,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flag_outlined,
                          color: Color(AppConstants.purple),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nova Meta',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(AppConstants.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    ChildDashboardState state,
    bool isSmallScreen,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimas Transações',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(AppConstants.textPrimary),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegar para todas as transações
                },
                child: Text(
                  'Ver todas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(AppConstants.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          if (state.recentTransactions.isEmpty)
            const EmptyState(
              emoji: '📝',
              title: 'Nenhuma transação',
              message: 'Comece registrando seus gastos!',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentTransactions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.spacingMedium),
              itemBuilder: (context, index) {
                final transaction = state.recentTransactions[index];
                return TransactionCard(transaction: transaction);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAchievements(
    BuildContext context,
    ChildDashboardState state,
    bool isSmallScreen,
  ) {
    final completedAchievements = state.achievements
        .where((a) => a.isCompleted)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suas Conquistas',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(AppConstants.textPrimary),
                ),
              ),
              Text(
                '$completedAchievements de ${state.achievements.length}',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(AppConstants.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.achievements.take(3).length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppConstants.spacingMedium),
            itemBuilder: (context, index) {
              final achievement = state.achievements[index];
              return AchievementCard(achievement: achievement, compact: true);
            },
          ),
        ],
      ),
    );
  }
}
