import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../shared/widgets/widgets.dart';
import '../bloc/parent_dashboard_cubit.dart';
import '../bloc/parent_dashboard_state.dart';
import '../widgets/parent_dashboard_skeleton.dart';

class ParentDependentsScreen extends StatelessWidget {
  const ParentDependentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandedRefreshIndicator(
        onRefresh: () => context.read<ParentDashboardCubit>().refresh(),
        child: BlocBuilder<ParentDashboardCubit, ParentDashboardState>(
          builder: (context, state) {
            if (state.isLoading && state.children.isEmpty) {
              return const ParentDashboardSkeleton();
            }

            if (state.children.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: EmptyState(
                    emoji: '👥',
                    title: 'Nenhum dependente cadastrado',
                    message:
                        'Adicione uma criança para começar a acompanhar as finanças em família.',
                  ),
                ),
              );
            }

            return SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                itemCount: state.children.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppConstants.spacingMedium),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dependentes',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Acompanhe o saldo e os hábitos de cada criança.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                      ],
                    );
                  }

                  final child = state.children[index - 1];
                  final spending = state.totalSpendingByChild[child.id] ?? 0.0;

                  return CustomCard(
                    color: Theme.of(context).colorScheme.surface,
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: child.gender == Gender.male
                                ? const Color(AppConstants.primaryBlue)
                                    .withOpacity(0.1)
                                : const Color(AppConstants.pink)
                                    .withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMedium),
                          ),
                          child: Icon(
                            Icons.person,
                            color: child.gender == Gender.male
                                ? const Color(AppConstants.primaryBlue)
                                : const Color(AppConstants.pink),
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
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${child.age} anos',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.65),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Saldo: ${AppFormatters.formatCurrency(child.balance)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(
                                          AppConstants.successGreen,
                                        ),
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
                              'Gastos no mês',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(spending),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

