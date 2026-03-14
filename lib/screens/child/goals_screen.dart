import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy_login/models/goal.dart';
import 'package:lummy_login/screens/child/new_goal_screen.dart';
import 'package:lummy_login/shared/widgets/money_text_field.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';
import 'package:lummy_login/utils/ensure_child_record.dart';

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
        debugPrint('❌ Usuário não autenticado');
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
      debugPrint('❌ Erro ao carregar metas: $e');
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
      debugPrint('⚠️ Erro ao sincronizar meta com balance: $e');
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
        debugPrint('✅ Meta atual carregada: ${currentGoal?.name}');
      } else {
        setState(() {
          currentGoal = null;
        });
        debugPrint('ℹ️ Nenhuma meta em andamento encontrada');
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar meta atual: $e');
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
        debugPrint('✅ ${completedGoals.length} metas concluídas carregadas');
      } else {
        setState(() {
          completedGoals = [];
        });
        debugPrint('ℹ️ Nenhuma meta concluída encontrada');
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar metas concluídas: $e');
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
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
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
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              backgroundColor: const Color(0xFFEF4444),
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
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF8B5CF6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        debugPrint('❌ Erro ao criar meta: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar meta: $e',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFFEF4444),
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
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao atualizar progresso: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao atualizar progresso: $e',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
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
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao completar meta: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao completar meta: $e',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
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
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao deletar meta: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao remover meta: $e',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFEF4444),
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
        ? _buildSkeletonLoader()
        : BrandedRefreshIndicator(
            onRefresh: _loadGoals,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Hero: gradiente + título + stats
                SliverToBoxAdapter(
                  child: _buildGoalsHero(
                    context,
                    isSmallScreen,
                    isDark,
                    topPadding,
                    ongoingCount: goal != null ? 1 : 0,
                    completedCount: completedGoals.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                if (goal != null) ...[
                  SliverToBoxAdapter(
                    child: _buildFeaturedGoalCard(goal, isSmallScreen)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ] else ...[
                  SliverToBoxAdapter(
                    child: _buildEmptyState(isSmallScreen)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
                if (completedGoals.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionHeader(
                        'Concluídas',
                        completedGoals.length,
                        isSmallScreen,
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
                            child: _buildGoalCard(g, isSmallScreen)
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
          : _buildFloatingAddGoalButton(context, isSmallScreen),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGoalsHero(
    BuildContext context,
    bool isSmallScreen,
    bool isDark,
    double topPadding, {
    required int ongoingCount,
    required int completedCount,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF5B21B6),
                  const Color(0xFF7C3AED),
                  const Color(0xFF6366F1),
                ]
              : [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF7C3AED),
                  const Color(0xFF6366F1),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.35),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.flag_rounded,
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
                      'Minhas Metas',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transforme sonhos em realidade',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeroStatChip(
                Icons.trending_up_rounded,
                '$ongoingCount em andamento',
                isSmallScreen,
              ),
              const SizedBox(width: 10),
              _buildHeroStatChip(
                Icons.celebration_rounded,
                '$completedCount concluídas',
                isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatChip(
    IconData icon,
    String label,
    bool isSmallScreen,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isSmallScreen ? 16 : 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedGoalCard(Goal goal, bool isSmallScreen) {
    final primaryColor = goal.status == GoalStatus.completed
        ? const Color(0xFF10B981)
        : const Color(0xFF8B5CF6);
    final progress = goal.progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withOpacity(isDark ? 0.25 : 0.4),
            width: isDark ? 1.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(isDark ? 0.15 : 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.12),
              blurRadius: isDark ? 12 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: isSmallScreen ? 72 : 88,
                  height: isSmallScreen ? 72 : 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: isSmallScreen ? 72 : 88,
                        height: isSmallScreen ? 72 : 88,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: primaryColor.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          goal.emoji,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 28 : 34,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          goal.status == GoalStatus.completed
                              ? 'Concluída'
                              : 'Em andamento',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.name,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(progress * 100).toInt()}% • ${_formatCurrency(goal.currentAmount)} / ${_formatCurrency(goal.targetAmount)}',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: primaryColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            if (goal.status != GoalStatus.completed) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildCardActionButton(
                      context,
                      Icons.add_circle_rounded,
                      'Adicionar economia',
                      primaryColor,
                      onTap: () => _showAddProgressDialog(goal),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCardActionButton(
                      context,
                      Icons.check_circle_outline_rounded,
                      'Marcar concluída',
                      const Color(0xFF10B981),
                      onTap: () => _markGoalAsCompleted(goal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCardActionButton(
                context,
                Icons.delete_outline_rounded,
                'Remover meta',
                const Color(0xFFEF4444),
                onTap: () => _showDeleteConfirmation(goal),
                fullWidth: true,
              ),
            ],
            if (goal.status == GoalStatus.completed &&
                goal.completedDate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Concluída em ${_formatDate(goal.completedDate!)}',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Widget _buildCardActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
    bool fullWidth = false,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            mainAxisAlignment:
                fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget _buildFloatingAddGoalButton(BuildContext context, bool isSmallScreen) {
    return FloatingActionButton.extended(
      heroTag: 'fab_goals',
      onPressed: _addNewGoal,
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded, size: 24),
      label: Text(
        'Nova meta',
        style: GoogleFonts.poppins(
          fontSize: isSmallScreen ? 14 : 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevation: 4,
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isSmallScreen) {
    final bool isCompleted = title == 'Concluídas';
    final Color headerColor = isCompleted
        ? const Color(0xFF10B981)
        : const Color(0xFF8B5CF6);
    final IconData headerIcon = isCompleted ? Icons.check_circle : Icons.flag;

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: dark
              ? [headerColor.withOpacity(0.05), headerColor.withOpacity(0.02)]
              : [headerColor.withOpacity(0.12), headerColor.withOpacity(0.06)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: headerColor.withOpacity(dark ? 0.1 : 0.25),
          width: dark ? 1 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(dark ? 0.1 : 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              headerIcon,
              color: headerColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  headerColor.withOpacity(0.2),
                  headerColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: headerColor.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: headerColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tag, size: 14, color: headerColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: headerColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, bool isSmallScreen) {
    // Define colors based on goal status and progress
    final Color primaryColor = goal.status == GoalStatus.completed
        ? const Color(0xFF10B981) // Green for completed
        : const Color(0xFF8B5CF6); // Purple for ongoing

    final Color secondaryColor = goal.status == GoalStatus.completed
        ? const Color(0xFF059669)
        : const Color(0xFF7C3AED);

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goal.status == GoalStatus.completed
              ? primaryColor.withOpacity(dark ? 0.2 : 0.35)
              : primaryColor.withOpacity(dark ? 0.15 : 0.3),
          width: dark ? 1.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(dark ? 0.1 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.03 : 0.08),
            blurRadius: dark ? 8 : 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with enhanced styling
          Row(
            children: [
              // Enhanced emoji container with solid color
              Container(
                width: isSmallScreen ? 52 : 60,
                height: isSmallScreen ? 52 : 60,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    goal.emoji,
                    style: TextStyle(fontSize: isSmallScreen ? 26 : 30),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: goal.status == GoalStatus.completed
                                ? const Color(0xFF10B981).withOpacity(0.1)
                                : const Color(0xFF8B5CF6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: goal.status == GoalStatus.completed
                                  ? const Color(0xFF10B981).withOpacity(0.3)
                                  : const Color(0xFF8B5CF6).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                goal.status == GoalStatus.completed
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                size: 12,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                goal.status == GoalStatus.completed
                                    ? 'Concluída'
                                    : 'Em Andamento',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (goal.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar - visible track + centered percentage
          SizedBox(
            height: 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Track
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD1D5DB),
                      width: 1,
                    ),
                  ),
                ),
                // Fill
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: goal.progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [primaryColor, secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Centered label over the bar
                IgnorePointer(
                  ignoring: true,
                  child: Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: goal.progress > 0.5 ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Enhanced Progress Text with better layout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progresso',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(goal.progress * 100).toInt()}% concluído',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: primaryColor.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Valor',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'R\$ ${goal.currentAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        '/ R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Completion status
          if (goal.status == GoalStatus.completed &&
              goal.completedDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    Icons.celebration,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '🎉 Concluída em ${_formatDate(goal.completedDate!)}',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSmallScreen) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Enhanced icon container with gradient
            Container(
              width: isSmallScreen ? 120 : 140,
              height: isSmallScreen ? 120 : 140,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 70,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🚀 Comece sua jornada!',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma meta criada ainda',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie sua primeira meta e comece a transformar seus sonhos em realidade!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _addNewGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      completedGoals.isNotEmpty
                          ? 'criar nova meta'
                          : 'Criar Primeira Meta',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProgressDialog(Goal goal) {
    final controller = TextEditingController();
    double? currentAmount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text('💰', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Adicionar Progresso',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quanto você economizou para "${goal.name}"?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                MoneyTextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {
                      currentAmount = value;
                    });
                  },
                  isSmallScreen: false,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
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
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Adicionar',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text('⚠️', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Excluir Meta',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tem certeza que deseja excluir',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${goal.name}"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta ação não pode ser desfeita.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _deleteGoal(goal);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Excluir',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            height: 32,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),
          // Current goal skeleton
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          // Completed goals title skeleton
          Container(
            height: 24,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          // Completed goals list skeleton
          ...List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == 2 ? 0 : 16),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'hoje';
    } else if (difference == 1) {
      return 'ontem';
    } else if (difference < 7) {
      return '$difference dias atrás';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks semana${weeks > 1 ? 's' : ''} atrás';
    } else {
      final months = (difference / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    }
  }
}
