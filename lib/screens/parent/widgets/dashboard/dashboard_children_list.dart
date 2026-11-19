import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/utils/formatters.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/domain/entities/user_entity.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_cubit.dart';
import 'package:lummy/features/parent/presentation/bloc/parent_dashboard_state.dart';
import 'package:lummy/core/theme/design_tokens.dart';

/// Lista de dependentes do dashboard.
///
/// Atualmente não é usada por nenhuma tela (era o método não utilizado
/// _buildChildrenList de ParentDashboardScreen).
class DashboardChildrenList extends StatelessWidget {
  final ParentDashboardState state;
  final EdgeInsetsGeometry? margin;

  const DashboardChildrenList({
    super.key,
    required this.state,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ??
          const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dependentes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          if (state.children.isEmpty)
            const EmptyState(
              emoji: '👥',
              title: 'Nenhum dependente cadastrado',
              message: 'Inclua uma criança para começar a acompanhar os dados.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.children.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppConstants.spacingMedium),
              itemBuilder: (context, index) {
                final child = state.children[index];
                final spending = state.totalSpendingByChild[child.id] ?? 0.0;

                return CustomCard(
                  color: Theme.of(context).colorScheme.surface,
                  onTap: () {
                    context.read<ParentDashboardCubit>().selectChild(child);
                    // Navegar para detalhes da criança
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: child.gender == Gender.male
                              ? LummyColors.brandBlue.withValues(alpha: 0.1)
                              : LummyColors.pink500.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMedium,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: child.gender == Gender.male
                              ? LummyColors.brandBlue
                              : LummyColors.pink500,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: LummyFonts.body(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${child.age} anos',
                                  style: LummyFonts.body(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Saldo: ${AppFormatters.formatCurrency(child.balance)}',
                                    style: LummyFonts.body(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: LummyColors.emerald500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Gastos',
                            style: LummyFonts.body(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            AppFormatters.formatCurrency(spending),
                            style: LummyFonts.body(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppConstants.spacingSmall),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
