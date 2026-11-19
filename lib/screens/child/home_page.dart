import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/core/utils/network_errors.dart';
import 'package:lummy/screens/child/new_goal_screen.dart';
import 'package:lummy/screens/child/request_money_screen.dart';
import 'package:lummy/screens/child/claim_share_screen.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lummy/utils/child_money_notification.dart';
import 'package:lummy/screens/child/profile_page.dart';
import 'package:lummy/screens/child/daily_missions_screen.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/home/home_achievements_section.dart';
import 'package:lummy/screens/child/widgets/home/home_balance_card.dart';
import 'package:lummy/screens/child/widgets/home/home_education_section.dart';
import 'package:lummy/screens/child/widgets/home/home_educational_tips.dart';
import 'package:lummy/screens/child/widgets/home/home_empty_goal_card.dart';
import 'package:lummy/screens/child/widgets/home/home_header.dart';
import 'package:lummy/screens/child/widgets/home/home_quick_actions.dart';
import 'package:lummy/screens/child/widgets/home/home_savings_goal_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dados do usuário
  String userName = '';
  final String userRole = 'Pequeno Empreendedor';
  double currentBalance = 0.0;
  bool _balanceLoadFailed = false;
  double _weekIncomeTotal = 0.0;
  double savingsGoal = 0.0;
  String goalName = '';
  String goalEmoji = '🎯';
  double goalCurrentAmount = 0.0;
  bool hasActiveGoal = false;
  int _earnedMissionPoints = 0;
  RealtimeChannel? _goalsChannel;
  RealtimeChannel? _balanceChannel;
  RealtimeChannel? _customMissionsChannel;
  RealtimeChannel? _dailyMissionsChannel;
  RealtimeChannel? _achievementsChannel;
  bool _isLoading = true;
  bool _isClaimContextLoading = false;
  String? _activeDistributionId;
  double _activeDistributionAmount = 0.0;
  bool _alreadyClaimedCurrentDistribution = false;
  String _currentChildId = '';
  String _currentChildName = 'Você';
  List<Map<String, dynamic>> _realSiblings = const [];

  // Lista de transações
  List<Map<String, dynamic>> transactions = [];

  // Lista de conquistas
  List<Map<String, dynamic>> achievements = [
    {
      'id': 'first_saving',
      'title': 'Primeira Economia',
      'description': 'Você guardou seu primeiro dinheiro!',
      'emoji': '🥇',
      'isCompleted': true,
    },
    {
      'id': 'expense_control',
      'title': 'Controle de Gastos',
      'description': 'Anotou gastos por 7 dias seguidos',
      'emoji': '📊',
      'isCompleted': true,
    },
    {
      'id': 'goal_reached',
      'title': 'Meta Alcançada',
      'description': 'Complete sua primeira meta de economia',
      'emoji': '🎯',
      'isCompleted': false,
    },
  ];

  // Lista de dicas educativas - MUITAS dicas!
  int currentTipIndex = 0;
  final List<EducationalTip> educationalTips = buildHomeEducationalTips();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _subscribeGoalsRealtime();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await initChildMoneyNotifications();
      await Future.wait([
        _loadUserName(),
        _loadEarnedPoints(),
        _loadBalance(),
        _loadGoal(),
        _loadClaimContext(),
      ]);
    } catch (e) {
      debugLogDataLoad('Erro ao inicializar dados', e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _subscribeGoalsRealtime() {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      _balanceChannel = supabase
          .channel('public:children:balance:${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'children',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: user.id,
            ),
            callback: (payload) {
              // Usar o payload em tempo real para notificar na hora (não depender de nova consulta)
              try {
                final newRecord = payload.newRecord;
                final newBalance =
                    (newRecord['balance'] as num?)?.toDouble() ?? 0.0;
                if (mounted) {
                  setState(() {
                    currentBalance = newBalance;
                    _balanceLoadFailed = false;
                  });
                  checkAndNotifyBalanceIncrease(newBalance);
                }
              } catch (_) {}
              _loadBalance();
            },
          )
          .subscribe();

      _customMissionsChannel = supabase
          .channel('public:custom_missions:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'custom_missions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (_) {
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title: 'Nova missão adicionada! 🎯',
                body: 'Seu responsável criou uma missão para você.',
              );
            },
          )
          .subscribe();

      _dailyMissionsChannel = supabase
          .channel('public:daily_missions:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'daily_missions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (_) {
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
                title: 'Missão do dia recebida! ✅',
                body: 'Você recebeu uma nova missão diária.',
              );
            },
          )
          .subscribe();

      _achievementsChannel = supabase
          .channel('public:achievements:new')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'achievements',
            callback: (_) {
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
                title: 'Nova conquista disponível! 🏆',
                body: 'Seu responsável adicionou uma nova conquista.',
              );
            },
          )
          .subscribe();

      _goalsChannel = supabase
          .channel('public:goals:child_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'goals',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (payload) {
              _loadGoal();
              showChildEventNotification(
                id: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3,
                title: 'Nova meta criada! 🚀',
                body: 'Seu responsável adicionou uma nova meta.',
              );
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'goals',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (payload) => _loadGoal(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'goals',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'child_id',
              value: user.id,
            ),
            callback: (payload) => _loadGoal(),
          )
          .subscribe();
    } catch (e) {
      debugLogDataLoad('Erro ao assinar realtime', e);
    }
  }

  @override
  void dispose() {
    try {
      if (_balanceChannel != null) {
        Supabase.instance.client.removeChannel(_balanceChannel!);
      }
      if (_customMissionsChannel != null) {
        Supabase.instance.client.removeChannel(_customMissionsChannel!);
      }
      if (_dailyMissionsChannel != null) {
        Supabase.instance.client.removeChannel(_dailyMissionsChannel!);
      }
      if (_achievementsChannel != null) {
        Supabase.instance.client.removeChannel(_achievementsChannel!);
      }
      if (_goalsChannel != null) {
        Supabase.instance.client.removeChannel(_goalsChannel!);
      }
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      String? name;

      if (user != null) {

        // 1) Buscar na tabela children pelo id do usuário autenticado
        try {
          final childRow = await supabase
              .from('children')
              .select('nome')
              .eq('id', user.id)
              .maybeSingle();


          if (childRow != null && childRow['nome'] != null) {
            name = childRow['nome'] as String?;
          } else {
            appLog(
              '⚠️ Nome não encontrado na tabela children, tentando fallbacks...',
            );
          }
        } catch (e) {
          if (isNetworkFailure(e)) {
            debugLogDataLoad('Busca nome em children', e);
          } else {
            appLog('❌ Erro ao buscar na tabela children: $e');
            if (e is PostgrestException) {
              appLog('   Código: ${e.code}');
              appLog('   Mensagem: ${e.message}');
              appLog('   Detalhes: ${e.details}');
            }
          }
        }

        // 2) Fallback: metadata do usuário (caso exista)
        if (name == null || name.trim().isEmpty) {
          final meta = user.userMetadata ?? {};
          name =
              (meta['name'] ?? meta['full_name'] ?? meta['username'])
                  as String?;
          if (name != null) {
            appLog('✅ Nome encontrado no metadata: $name');
          }
        }

        // 3) Fallback: prefixo do email
        if (name == null || name.trim().isEmpty) {
          name = user.email?.split('@').first;
          if (name != null) {
            appLog('✅ Usando prefixo do email: $name');
          }
        }
      } else {
        appLog('⚠️ Nenhum usuário autenticado');
      }

      // 4) Fallback: valor salvo localmente (se existir)
      if (name == null || name.trim().isEmpty) {
        name = (await SharedPreferences.getInstance()).getString('user_name');
        if (name != null) {
          appLog('✅ Nome encontrado no SharedPreferences: $name');
        }
      }

      setState(() {
        userName = (name?.trim().isNotEmpty == true) ? name!.trim() : 'Usuário';
      });
    } catch (e, stackTrace) {
      debugLogDataLoad('Erro ao carregar nome do usuário', e, stackTrace);
      setState(() {
        userName = 'Usuário';
      });
    }
  }

  Future<void> _loadEarnedPoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _earnedMissionPoints = prefs.getInt('missions_earned_points') ?? 0;
    });
  }

  bool get _hasRealSiblings => _realSiblings.isNotEmpty;

  double get _currentWeightedScore {
    final completedAchievements = achievements
        .where((a) => a['isCompleted'] == true)
        .length
        .toDouble();
    final score = _earnedMissionPoints.toDouble() + (completedAchievements * 5.0);
    return score <= 0 ? 1.0 : score;
  }

  List<double> get _otherSiblingsScores =>
      List<double>.filled(_realSiblings.length, 1.0);

  List<String> get _otherSiblingsNames => _realSiblings
      .map((s) => (s['nome'] as String?)?.trim())
      .whereType<String>()
      .where((n) => n.isNotEmpty)
      .toList();

  Future<void> _loadClaimContext() async {
    setState(() => _isClaimContextLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _activeDistributionId = null;
          _activeDistributionAmount = 0.0;
          _alreadyClaimedCurrentDistribution = false;
          _currentChildId = '';
          _currentChildName = 'Você';
          _realSiblings = const [];
          _isClaimContextLoading = false;
        });
        return;
      }

      final me = await supabase
          .from('children')
          .select('id, nome, responsavel_id')
          .eq('id', user.id)
          .maybeSingle();
      if (me == null) {
        if (!mounted) return;
        setState(() {
          _activeDistributionId = null;
          _activeDistributionAmount = 0.0;
          _alreadyClaimedCurrentDistribution = false;
          _currentChildId = user.id;
          _currentChildName = 'Você';
          _realSiblings = const [];
          _isClaimContextLoading = false;
        });
        return;
      }

      final parentId = me['responsavel_id'] as String?;
      final childId = me['id'] as String? ?? user.id;
      final childName = ((me['nome'] as String?) ?? 'Você').trim();

      final siblings = parentId == null
          ? <Map<String, dynamic>>[]
          : (await supabase
                  .from('children')
                  .select('id, nome')
                  .eq('responsavel_id', parentId)
                  .neq('id', childId))
              .cast<Map<String, dynamic>>();

      Map<String, dynamic>? activeDistribution;
      if (parentId != null && siblings.isNotEmpty) {
        activeDistribution = await supabase
            .from('allowance_distributions')
            .select('id, total_amount')
            .eq('parent_id', parentId)
            .eq('status', 'active')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
      }

      bool alreadyClaimed = false;
      if (activeDistribution != null) {
        final claim = await supabase
            .from('allowance_claims')
            .select('id')
            .eq('distribution_id', activeDistribution['id'] as String)
            .eq('child_id', childId)
            .maybeSingle();
        alreadyClaimed = claim != null;
      }

      if (!mounted) return;
      setState(() {
        _activeDistributionId = activeDistribution?['id'] as String?;
        _activeDistributionAmount =
            (activeDistribution?['total_amount'] as num?)?.toDouble() ?? 0.0;
        _alreadyClaimedCurrentDistribution = alreadyClaimed;
        _currentChildId = childId;
        _currentChildName = childName.isEmpty ? 'Você' : childName;
        _realSiblings = siblings;
        _isClaimContextLoading = false;
      });
    } catch (e) {
      debugLogDataLoad('Contexto de resgate', e);
      if (!mounted) return;
      setState(() => _isClaimContextLoading = false);
    }
  }

  Future<void> _refreshData() async {
    try {
      // Recarregar todos os dados
      await Future.wait([
        _loadUserName(),
        _loadEarnedPoints(),
        _loadBalance(),
        _loadGoal(),
        _loadClaimContext(),
      ]);
    } catch (e) {
      debugLogDataLoad('Atualizar dados (refresh)', e);
    }
  }

  Future<void> _loadBalance() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          currentBalance = 0.0;
          _balanceLoadFailed = true;
          _weekIncomeTotal = 0.0;
        });
        return;
      }
      final row = await supabase
          .from('children')
          .select('balance')
          .eq('id', user.id)
          .maybeSingle();
      final bal = (row?['balance'] as num?)?.toDouble() ?? 0.0;

      final weekStart = DateTime.now().subtract(const Duration(days: 7));
      double weekIn = 0.0;
      try {
        final tRows = await supabase
            .from('transactions')
            .select('amount, type, status')
            .eq('child_id', user.id)
            .gte('date', weekStart.toIso8601String());
        for (final r in tRows) {
          final type = (r['type'] ?? '').toString();
          if (!['income', 'allowance', 'reward'].contains(type)) continue;
          final st = (r['status'] ?? '').toString();
          if (st.isNotEmpty &&
              st != 'approved' &&
              st != 'completed') {
            continue;
          }
          weekIn += (r['amount'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        debugLogDataLoad('Entradas da semana', e);
      }

      setState(() {
        currentBalance = bal;
        _balanceLoadFailed = false;
        _weekIncomeTotal = weekIn;
      });
      await checkAndNotifyBalanceIncrease(bal);

      // Sincronizar meta com o novo balance
      if (hasActiveGoal) {
        final goalRow = await supabase
            .from('goals')
            .select('id')
            .eq('child_id', user.id)
            .eq('status', 'ongoing')
            .maybeSingle();
        if (goalRow != null) {
          await _syncGoalWithBalance(goalRow['id'] as String);
          // Recarregar meta para atualizar a UI
          await _loadGoal();
        }
      }
    } catch (e) {
      debugLogDataLoad('Carregar saldo', e);
      setState(() => _balanceLoadFailed = true);
    }
  }

  Future<void> _syncGoalWithBalance(String goalId) async {
    try {
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

      // Buscar meta atual
      final goalRow = await supabase
          .from('goals')
          .select('target_amount, status')
          .eq('id', goalId)
          .maybeSingle();

      if (goalRow == null) return;

      final target = (goalRow['target_amount'] as num).toDouble();
      final status = goalRow['status'] as String;

      // Se já está concluída, não atualizar
      if (status == 'completed') return;

      final newAmount = balance.clamp(0.0, target);

      // Atualizar current_amount para refletir o cofrinho
      await supabase
          .from('goals')
          .update({'current_amount': newAmount})
          .eq('id', goalId)
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
            .eq('id', goalId)
            .eq('child_id', user.id);
      }
    } catch (e) {
      debugLogDataLoad('Sincronizar meta com saldo', e);
    }
  }

  Future<void> _loadGoal() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        appLog('❌ Usuário não autenticado ao carregar meta');
        setState(() {
          hasActiveGoal = false;
        });
        return;
      }

      final goalData = await supabase
          .from('goals')
          .select('*')
          .eq('child_id', user.id)
          .eq('status', 'ongoing')
          .maybeSingle();

      if (goalData != null) {
        // Sincronizar meta com cofrinho antes de exibir
        await _syncGoalWithBalance(goalData['id'] as String);

        // Recarregar meta atualizada
        final updatedGoal = await supabase
            .from('goals')
            .select('*')
            .eq('id', goalData['id'] as String)
            .maybeSingle();

        if (updatedGoal != null) {
          setState(() {
            goalName = updatedGoal['name'] as String;
            goalEmoji = updatedGoal['emoji'] as String? ?? '🎯';
            savingsGoal = (updatedGoal['target_amount'] as num).toDouble();
            final current = (updatedGoal['current_amount'] as num).toDouble();
            goalCurrentAmount = current > savingsGoal ? savingsGoal : current;
            hasActiveGoal = true;
          });
        } else {
          setState(() {
            goalName = goalData['name'] as String;
            goalEmoji = goalData['emoji'] as String? ?? '🎯';
            savingsGoal = (goalData['target_amount'] as num).toDouble();
            final current = (goalData['current_amount'] as num).toDouble();
            goalCurrentAmount = current > savingsGoal ? savingsGoal : current;
            hasActiveGoal = true;
          });
        }
      } else {
        // Se não há meta em andamento, mostrar a última meta concluída
        final lastCompleted = await supabase
            .from('goals')
            .select('*')
            .eq('child_id', user.id)
            .eq('status', 'completed')
            .order('completed_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (lastCompleted != null) {
          final target = (lastCompleted['target_amount'] as num).toDouble();
          setState(() {
            goalName = lastCompleted['name'] as String;
            goalEmoji = lastCompleted['emoji'] as String? ?? '🎯';
            savingsGoal = target;
            goalCurrentAmount = target; // meta concluída nunca excede o alvo
            hasActiveGoal = true; // Exibir cartão com status de concluída
          });
        } else {
          setState(() {
            hasActiveGoal = false;
            goalName = '';
            goalEmoji = '🎯';
            savingsGoal = 0.0;
            goalCurrentAmount = 0.0;
          });
        }
      }
    } catch (e) {
      debugLogDataLoad('Carregar meta na homepage', e);
      setState(() {
        hasActiveGoal = false;
      });
    }
  }

  void _nextTip() {
    setState(() {
      currentTipIndex = (currentTipIndex + 1) % educationalTips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const ChildHomeSkeleton()
            : BrandedRefreshIndicator(
                onRefresh: _refreshData,
                color: theme.colorScheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      HomeHeader(
                        userName: userName,
                        isSmallScreen: isSmallScreen,
                        onAvatarTap: _openProfile,
                      )
                          .animate()
                          .fadeIn(duration: 220.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      HomeBalanceCard(
                        isSmallScreen: isSmallScreen,
                        balanceLoadFailed: _balanceLoadFailed,
                        currentBalance: currentBalance,
                        weekIncomeTotal: _weekIncomeTotal,
                        onRetry: () => _loadBalance(),
                      )
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 260.ms)
                          .slideY(begin: 0.03, end: 0, curve: Curves.easeOut),
                      (hasActiveGoal
                              ? HomeSavingsGoalCard(
                                  isSmallScreen: isSmallScreen,
                                  savingsGoal: savingsGoal,
                                  goalCurrentAmount: goalCurrentAmount,
                                  goalName: goalName,
                                  goalEmoji: goalEmoji,
                                  currentBalance: currentBalance,
                                  balanceLoadFailed: _balanceLoadFailed,
                                )
                              : HomeEmptyGoalCard(
                                  isSmallScreen: isSmallScreen,
                                  onTap: _onEmptyGoalCardTap,
                                ))
                          .animate()
                          .fadeIn(delay: 140.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      HomeQuickActions(
                        isSmallScreen: isSmallScreen,
                        claimShareSubtitle: _claimShareSubtitle,
                        onDailyMissionsTap: _openDailyMissions,
                        onNewGoalTap: _onNewGoalTap,
                        onRequestMoneyTap: _openRequestMoney,
                        onClaimShareTap: _onClaimShareTap,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      HomeEducationSection(
                        isSmallScreen: isSmallScreen,
                        educationalTips: educationalTips,
                        currentTipIndex: currentTipIndex,
                        onNextTip: _nextTip,
                      )
                          .animate()
                          .fadeIn(delay: 260.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      HomeAchievementsSection(
                        isSmallScreen: isSmallScreen,
                        achievements: achievements,
                      )
                          .animate()
                          .fadeIn(delay: 320.ms, duration: 260.ms)
                          .slideY(begin: 0.02, end: 0, curve: Curves.easeOut),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  Future<void> _onEmptyGoalCardTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewGoalScreen()),
    );

    if (result != null) {
      // Recarregar meta do banco após criar nova meta
      await _loadGoal();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nova meta criada! 🎯',
              style: LummyFonts.body(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
          ),
        );
      }
    }
  }

  void _openDailyMissions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyMissionsScreen(),
      ),
    );
  }

  Future<void> _onNewGoalTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewGoalScreen(),
      ),
    );

    if (result != null) {
      // Recarregar meta do banco após criar nova meta
      await _loadGoal();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nova meta criada! 🎯',
              style: LummyFonts.body(
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: LummyColors.violet500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _openRequestMoney() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestMoneyScreen(),
      ),
    );
  }

  Future<void> _onClaimShareTap() async {
    if (_isClaimContextLoading) return;
    if (!_hasRealSiblings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não há irmãos cadastrados pelo mesmo responsável.',
          ),
        ),
      );
      return;
    }
    if (_activeDistributionId == null ||
        _activeDistributionAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sem valor ativo para resgate no momento.',
          ),
        ),
      );
      return;
    }
    if (_alreadyClaimedCurrentDistribution) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você já retirou sua parte desta distribuição.',
          ),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClaimShareScreen(
          distributionId: _activeDistributionId!,
          childId: _currentChildId,
          totalAmount: _activeDistributionAmount,
          currentChildScore: _currentWeightedScore,
          otherChildrenScores: _otherSiblingsScores,
          otherChildrenNames: _otherSiblingsNames,
          currentChildName: _currentChildName,
        ),
      ),
    );
    if (result is Map && result['claimed'] == true) {
      final claimedAmount =
          ((result['amount'] ?? 0.0) as double);
      await _refreshData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Você retirou R\$ ${claimedAmount.toStringAsFixed(2)}',
            style: LummyFonts.body(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: LummyColors.emerald500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  String get _claimShareSubtitle => _isClaimContextLoading
      ? 'Carregando distribuição...'
      : (!_hasRealSiblings
            ? 'Inativo: sem irmãos cadastrados'
            : (_alreadyClaimedCurrentDistribution
                  ? 'Você já retirou nesta distribuição'
                  : (_activeDistributionId == null
                        ? 'Sem distribuição ativa'
                        : 'Resgate sua parte do valor do responsável')));
}
