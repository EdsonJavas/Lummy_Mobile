import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy/models/goal.dart';
import 'package:lummy/screens/child/new_goal_screen.dart';
import 'package:lummy/screens/child/widgets/goals/goals_add_goal_fab.dart';
import 'package:lummy/screens/child/widgets/goals/goals_add_progress_dialog.dart';
import 'package:lummy/screens/child/widgets/goals/goals_celebration_banner.dart';
import 'package:lummy/screens/child/widgets/goals/goals_delete_confirmation_dialog.dart';
import 'package:lummy/screens/child/widgets/goals/goals_empty_hint.dart';
import 'package:lummy/screens/child/widgets/goals/goals_featured_goal_card.dart';
import 'package:lummy/screens/child/widgets/goals/goals_goal_card.dart';
import 'package:lummy/screens/child/widgets/goals/goals_hero.dart';
import 'package:lummy/screens/child/widgets/goals/goals_section_header.dart';
import 'package:lummy/screens/child/widgets/goals/goals_skeleton_loader.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/utils/ensure_child_record.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Goal? currentGoal;
  List<Goal> completedGoals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        appLog('❌ Usuário não autenticado');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Carregar meta em andamento
      await _loadCurrentGoal();

      // Sincronizar progresso da meta com o cofrinho (children.balance)
      await _syncGoalWithBalance();

      // Carregar metas concluídas
      await _loadCompletedGoals();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      appLog('❌ Erro ao carregar metas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncGoalWithBalance() async {
    try {
      if (currentGoal == null || currentGoal!.status == GoalStatus.completed) {
        return;
      }

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Buscar saldo do cofrinho
      final childRow = await supabase
          .from('children')
          .select('balance')
          .eq('id', user.id)
          .maybeSingle();
      final balance = (childRow?['balance'] as num?)?.toDouble() ?? 0.0;

      final goal = currentGoal!;
      final target = goal.targetAmount;
      final newAmount = balance.clamp(0.0, target);

      // Atualizar current_amount para refletir o cofrinho
      await supabase
          .from('goals')
          .update({'current_amount': newAmount})
          .eq('id', goal.id)
          .eq('child_id', user.id);

      // Se atingiu ou superou o alvo, marcar como concluída
      if (balance >= target) {
        await supabase
            .from('goals')
            .update({
              'status': 'completed',
              'current_amount': target,
              'completed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', goal.id)
            .eq('child_id', user.id);
      }

      // Recarregar metas para refletir mudanças
      await _loadCurrentGoal();
    } catch (e) {
      appLog('⚠️ Erro ao sincronizar meta com balance: $e');
    }
  }

  Future<void> _loadCurrentGoal() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final goalData = await supabase
          .from('goals')
          .select('*')
          .eq('child_id', user.id)
          .eq('status', 'ongoing')
          .maybeSingle();

      if (goalData != null) {
        setState(() {
          currentGoal = Goal(
            id: goalData['id'] as String,
            name: goalData['name'] as String,
            emoji: goalData['emoji'] as String? ?? '🎯',
            targetAmount: (goalData['target_amount'] as num).toDouble(),
            currentAmount: (goalData['current_amount'] as num).toDouble(),
            status: (goalData['status'] as String) == 'completed'
                ? GoalStatus.completed
                : GoalStatus.ongoing,
            createdDate: DateTime.parse(goalData['created_at'] as String),
            completedDate: goalData['completed_at'] != null
                ? DateTime.parse(goalData['completed_at'] as String)
                : null,
            description: goalData['description'] as String? ?? '',
          );
        });
      } else {
        setState(() {
          currentGoal = null;
        });
      }
    } catch (e) {
      appLog('❌ Erro ao carregar meta atual: $e');
      setState(() {
        currentGoal = null;
      });
    }
  }

  Future<void> _loadCompletedGoals() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final completedGoalsData = await supabase
          .from('goals')
          .select('*')
          .eq('child_id', user.id)
          .eq('status', 'completed')
          .order('completed_at', ascending: false);

      if (completedGoalsData.isNotEmpty) {
        setState(() {
          completedGoals = completedGoalsData.map((data) {
            return Goal(
              id: data['id'] as String,
              name: data['name'] as String,
              emoji: data['emoji'] as String? ?? '🎯',
              targetAmount: (data['target_amount'] as num).toDouble(),
              currentAmount: (data['current_amount'] as num).toDouble(),
              status: GoalStatus.completed,
              createdDate: DateTime.parse(data['created_at'] as String),
              completedDate: data['completed_at'] != null
                  ? DateTime.parse(data['completed_at'] as String)
                  : null,
              description: data['description'] as String? ?? '',
            );
          }).toList();
        });
      } else {
        setState(() {
          completedGoals = [];
        });
      }
    } catch (e) {
      appLog('❌ Erro ao carregar metas concluídas: $e');
      setState(() {
        completedGoals = [];
      });
    }
  }

  Future<void> _addNewGoal() async {
    // Verificar se já existe uma meta em andamento
    if (currentGoal != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Você já tem uma meta em andamento! Complete ou remova a meta atual antes de criar uma nova.',
            style: LummyFonts.body(fontWeight: FontWeight.w500),
          ),
          backgroundColor: LummyColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewGoalScreen()),
    );

    if (result != null && mounted) {
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user == null) {
          throw Exception('Usuário não autenticado');
        }

        // Garantir que o registro existe na tabela children
        final childExists = await EnsureChildRecord.ensureChildExists();
        if (!childExists) {
          throw Exception(
            'Não foi possível criar o registro do usuário. Verifique se você foi registrado por um responsável.',
          );
        }

        // Verificar novamente se não há meta em andamento (race condition)
        final existingGoal = await supabase
            .from('goals')
            .select('id')
            .eq('child_id', user.id)
            .eq('status', 'ongoing')
            .maybeSingle();

        if (existingGoal != null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Você já tem uma meta em andamento!',
                style: LummyFonts.body(fontWeight: FontWeight.w500),
              ),
              backgroundColor: LummyColors.red500,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          return;
        }

        // Criar nova meta no banco
        await supabase.from('goals').insert({
          'child_id': user.id,
          'name': result['name'].toString().trim(),
          'emoji': (result['emoji'] as String? ?? '🎯').trim(),
          'target_amount': (result['amount'] as num).toDouble(),
          'current_amount': 0.0,
          'status': 'ongoing', // Garantir que seja exatamente 'ongoing'
          'description': '',
        });

        // Recarregar metas
        await _loadGoals();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nova meta criada! 🎯',
              style: LummyFonts.body(fontWeight: FontWeight.w500),
            ),
            backgroundColor: LummyColors.violet500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        appLog('❌ Erro ao criar meta: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar meta: $e',
              style: LummyFonts.body(fontWeight: FontWeight.w500),
            ),
            backgroundColor: LummyColors.red500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateGoalProgress(Goal goal, double amount) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final newAmount = goal.currentAmount + amount;
      final targetAmount = goal.targetAmount;

      // Atualizar no banco
      await supabase
          .from('goals')
          .update({'current_amount': newAmount.clamp(0.0, targetAmount)})
          .eq('id', goal.id)
          .eq('child_id', user.id);

      // Recarregar metas (para pegar atualização automática de status se completou)
      await _loadGoals();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Progresso adicionado! 💰',
            style: LummyFonts.body(fontWeight: FontWeight.w500),
          ),
          backgroundColor: LummyColors.emerald500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      appLog('❌ Erro ao atualizar progresso: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao atualizar progresso: $e',
            style: LummyFonts.body(fontWeight: FontWeight.w500),
          ),
          backgroundColor: LummyColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _markGoalAsCompleted(Goal goal) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Atualizar meta para concluída
      await supabase
          .from('goals')
          .update({
            'status': 'completed',
            'current_amount': goal.targetAmount,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', goal.id)
          .eq('child_id', user.id);

      // Recarregar metas
      await _loadGoals();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meta concluída! 🎉',
            style: LummyFonts.body(fontWeight: FontWeight.w500),
          ),
          backgroundColor: LummyColors.emerald500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      appLog('❌ Erro ao completar meta: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao completar meta: $e',
            style: LummyFonts.body(fontWeight: FontWeight.w500),
          ),
          backgroundColor: LummyColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _deleteGoal(Goal goal) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Deletar do banco
      await supabase
          .from('goals')
          .delete()
          .eq('id', goal.id)
          .eq('child_id', user.id);

      // Recarregar metas
      await _loadGoals();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meta removida',
            style: LummyFonts.body(fontWeight: FontWeight.w500),
          ),
          backgroundColor: LummyColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      appLog('❌ Erro ao deletar meta: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao remover meta: $e',
            style: LummyFonts.body(fontWeight: FontWeight.w500),
          ),
          backgroundColor: LummyColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final goal = currentGoal;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final Widget bodyContent = _isLoading
        ? const GoalsSkeletonLoader()
        : BrandedRefreshIndicator(
            onRefresh: _loadGoals,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Hero: gradiente + título + stats
                SliverToBoxAdapter(
                  child: GoalsHero(
                    isSmallScreen: isSmallScreen,
                    isDark: isDark,
                    topPadding: topPadding,
                    ongoingCount: goal != null ? 1 : 0,
                    completedCount: completedGoals.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                if (goal != null) ...[
                  SliverToBoxAdapter(
                    child: GoalsFeaturedGoalCard(
                      goal: goal,
                      isSmallScreen: isSmallScreen,
                      onAddProgress: () => _showAddProgressDialog(goal),
                      onMarkCompleted: () => _markGoalAsCompleted(goal),
                      onDelete: () => _showDeleteConfirmation(goal),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ] else ...[
                  if (completedGoals.isNotEmpty) ...[
                    // Celebration banner when only completed goals exist
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GoalsCelebrationBanner(isSmallScreen: isSmallScreen)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ] else ...[
                    // Subtle hint when truly nothing exists
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                        child: GoalsSubtleEmptyHint(isSmallScreen: isSmallScreen),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                ],
                if (completedGoals.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GoalsSectionHeader(
                        title: goal == null ? 'Todas Concluídas' : 'Concluídas',
                        count: completedGoals.length,
                        isSmallScreen: isSmallScreen,
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms)
                          .slideX(begin: -0.03, end: 0, curve: Curves.easeOut),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final g = completedGoals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GoalsGoalCard(goal: g, isSmallScreen: isSmallScreen)
                              .animate()
                              .fadeIn(
                                delay: (120 + index * 60).ms,
                                duration: 320.ms,
                              )
                              .slideY(
                                begin: 0.06,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                            );
                        },
                        childCount: completedGoals.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ] else ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: bodyContent),
      floatingActionButton: _isLoading
          ? null
          : GoalsAddGoalFab(isSmallScreen: isSmallScreen, onPressed: _addNewGoal),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showAddProgressDialog(Goal goal) {
    final controller = TextEditingController();
    double? currentAmount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => GoalsAddProgressDialog(
          goal: goal,
          controller: controller,
          onAmountChanged: (value) {
            setState(() {
              currentAmount = value;
            });
          },
          onCancel: () => Navigator.pop(context),
          onConfirm: () {
            if (currentAmount != null && currentAmount! > 0) {
              _updateGoalProgress(goal, currentAmount!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.celebration,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Progresso adicionado! 💰',
                        style: LummyFonts.body(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: LummyColors.emerald500,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => GoalsDeleteConfirmationDialog(
        goal: goal,
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          _deleteGoal(goal);
          Navigator.pop(context);
        },
      ),
    );
  }
}
