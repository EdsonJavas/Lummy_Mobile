import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/utils/ensure_child_record.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/daily_missions/daily_mission_completion_dialog.dart';
import 'package:lummy/screens/child/widgets/daily_missions/daily_missions_error_view.dart';
import 'package:lummy/screens/child/widgets/daily_missions/daily_missions_header.dart';
import 'package:lummy/screens/child/widgets/daily_missions/daily_missions_list.dart';
import 'package:lummy/screens/child/widgets/daily_missions/daily_missions_skeleton.dart';

class DailyMissionsScreen extends StatefulWidget {
  const DailyMissionsScreen({super.key});

  @override
  State<DailyMissionsScreen> createState() => _DailyMissionsScreenState();
}

class _DailyMissionsScreenState extends State<DailyMissionsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> missions = [];
  int totalPoints = 0;
  int earnedPoints = 0;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _loadDailyMissions();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyMissions() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

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


      // Chamar função para selecionar/buscar missões do dia
      final today = DateTime.now().toIso8601String().split(
        'T',
      )[0]; // YYYY-MM-DD

      final result = await supabase.rpc(
        'select_daily_missions',
        params: {'p_child_id': user.id, 'p_selected_date': today},
      );


      if (result != null && result.isNotEmpty) {
        // Buscar status de conclusão das missões
        final dailyMissionsData = await supabase
            .from('daily_missions')
            .select('mission_id, is_completed, progress, points_earned')
            .eq('child_id', user.id)
            .eq('selected_date', today);

        final completedMap = <String, Map<String, dynamic>>{};
        for (var dm in dailyMissionsData) {
          completedMap[dm['mission_id'] as String] = {
            'is_completed': dm['is_completed'] ?? false,
            'progress': dm['progress'] ?? 0,
            'points_earned': dm['points_earned'] ?? 0,
          };
        }

        // Converter resultado para lista de missões
        final missionsList = <Map<String, dynamic>>[];
        int totalPointsToday = 0;
        int earnedPointsToday = 0;

        for (var missionData in result) {
          final missionId = missionData['mission_id'] as String;
          final status = completedMap[missionId];
          final isCompleted = status?['is_completed'] ?? false;
          final progress = status?['progress'] ?? 0;
          final points = missionData['points'] as int;

          totalPointsToday += points;
          if (isCompleted) {
            earnedPointsToday += points;
          }

          missionsList.add({
            'id': missionId,
            'title': missionData['title'] as String,
            'description': missionData['description'] as String,
            'emoji': missionData['emoji'] as String,
            'points': points,
            'progress': progress,
            'total': missionData['progress_target'] as int,
            'isCompleted': isCompleted,
            'color': _hexToColor(missionData['color_hex'] as String),
          });
        }

        setState(() {
          missions = missionsList;
          totalPoints = totalPointsToday;
          earnedPoints = earnedPointsToday;
        });

      } else {
        // Se não retornou missões, pode ser que a função não exista ainda
        // Tentar buscar diretamente
        appLog('⚠️ Função não retornou missões, tentando busca direta...');
        await _loadMissionsDirectly(user.id, today);
      }
    } catch (e) {
      appLog('❌ Erro ao carregar missões: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar missões: $e';
        missions = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMissionsDirectly(String userId, String today) async {
    try {
      final supabase = Supabase.instance.client;

      // Verificar se já existem missões para hoje
      final existingMissions = await supabase
          .from('daily_missions')
          .select('mission_id, is_completed, progress, points_earned')
          .eq('child_id', userId)
          .eq('selected_date', today);

      if (existingMissions.isNotEmpty) {
        // Buscar dados das missões
        final missionIds = existingMissions
            .map((m) => m['mission_id'] as String)
            .toList();

        // Usar .or() para filtrar múltiplos IDs (workaround para IN clause)
        var query = supabase.from('missions').select('*');
        if (missionIds.length == 1) {
          query = query.eq('id', missionIds[0]);
        } else if (missionIds.length > 1) {
          // Formato: 'id.eq.value1,id.eq.value2' para OR
          final orFilter = missionIds.map((id) => 'id.eq.$id').join(',');
          query = query.or(orFilter);
        }

        final missionsData = await query;

        final missionsList = <Map<String, dynamic>>[];
        int totalPointsToday = 0;
        int earnedPointsToday = 0;

        for (var mission in missionsData) {
          final missionId = mission['id'] as String;
          final dailyMission = existingMissions.firstWhere(
            (dm) => dm['mission_id'] == missionId,
            orElse: () => {},
          );

          final isCompleted = dailyMission['is_completed'] ?? false;
          final progress = dailyMission['progress'] ?? 0;
          final points = mission['points'] as int;

          totalPointsToday += points;
          if (isCompleted) {
            earnedPointsToday += points;
          }

          missionsList.add({
            'id': missionId,
            'title': mission['title'] as String,
            'description': mission['description'] as String,
            'emoji': mission['emoji'] as String,
            'points': points,
            'progress': progress,
            'total': mission['progress_target'] as int,
            'isCompleted': isCompleted,
            'color': _hexToColor(mission['color_hex'] as String),
          });
        }

        setState(() {
          missions = missionsList;
          totalPoints = totalPointsToday;
          earnedPoints = earnedPointsToday;
        });
      } else {
        // Não há missões para hoje, selecionar 5 aleatórias
        await _selectRandomMissions(userId, today);
      }
    } catch (e) {
      appLog('❌ Erro ao carregar missões diretamente: $e');
      rethrow;
    }
  }

  Future<void> _selectRandomMissions(String userId, String today) async {
    try {
      final supabase = Supabase.instance.client;

      // Buscar todas as missões ativas
      final allMissions = await supabase
          .from('missions')
          .select('*')
          .eq('is_active', true);

      if (allMissions.isEmpty) {
        throw Exception('Nenhuma missão disponível no sistema');
      }

      // Embaralhar e pegar 5
      allMissions.shuffle();
      final selectedMissions = allMissions.take(5).toList();

      // Inserir na tabela daily_missions
      for (var mission in selectedMissions) {
        await supabase.from('daily_missions').insert({
          'child_id': userId,
          'mission_id': mission['id'],
          'selected_date': today,
          'is_completed': false,
          'progress': 0,
        });
      }

      // Recarregar missões
      await _loadMissionsDirectly(userId, today);
    } catch (e) {
      appLog('❌ Erro ao selecionar missões aleatórias: $e');
      rethrow;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Adicionar alpha se não tiver
    }
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> _completeMission(String missionId) async {
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

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Tentar usar a função do banco
      try {
        final result = await supabase
            .rpc(
              'complete_daily_mission',
              params: {
                'p_child_id': user.id,
                'p_mission_id': missionId,
                'p_selected_date': today,
              },
            )
            .single();

        final pointsEarned = result['points_earned'] as int;

        // Atualizar estado local
        setState(() {
          final mission = missions.firstWhere((m) => m['id'] == missionId);
          mission['isCompleted'] = true;
          mission['progress'] = mission['total'];
          earnedPoints += pointsEarned;
        });

        // Mostrar diálogo de sucesso
        _showCompletionDialog(missionId, pointsEarned);
      } catch (e) {
        // Se a função não existir, atualizar manualmente
        appLog('⚠️ Função não disponível, atualizando manualmente: $e');
        await _completeMissionManually(missionId, user.id, today);
      }
    } catch (e) {
      appLog('❌ Erro ao completar missão: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao completar missão: $e',
            style: LummyFonts.body(),
          ),
          backgroundColor: LummyColors.red500,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _completeMissionManually(
    String missionId,
    String userId,
    String today,
  ) async {
    try {
      final supabase = Supabase.instance.client;

      // Buscar dados da missão
      final missionData = await supabase
          .from('missions')
          .select('points, progress_target')
          .eq('id', missionId)
          .single();

      final points = missionData['points'] as int;
      final progressTarget = missionData['progress_target'] as int;

      // Atualizar daily_missions
      await supabase
          .from('daily_missions')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
            'progress': progressTarget,
            'points_earned': points,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('child_id', userId)
          .eq('mission_id', missionId)
          .eq('selected_date', today)
          .eq('is_completed', false);

      // Buscar pontos atuais
      final childData = await supabase
          .from('children')
          .select('total_points, level')
          .eq('id', userId)
          .single();

      final currentPoints = (childData['total_points'] as int?) ?? 0;

      final newPoints = currentPoints + points;
      final newLevel =
          (newPoints / 1000).floor() + 1; // Nível sobe a cada 1000 pontos

      // Atualizar pontos e nível
      await supabase
          .from('children')
          .update({
            'total_points': newPoints,
            'level': newLevel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);


      // Atualizar estado local
      setState(() {
        final mission = missions.firstWhere((m) => m['id'] == missionId);
        mission['isCompleted'] = true;
        mission['progress'] = progressTarget;
        earnedPoints += points;
      });

      // Mostrar diálogo de sucesso
      _showCompletionDialog(missionId, points);
    } catch (e) {
      appLog('❌ Erro ao completar missão manualmente: $e');
      rethrow;
    }
  }

  void _showCompletionDialog(String missionId, int pointsEarned) {
    final mission = missions.firstWhere((m) => m['id'] == missionId);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DailyMissionCompletionDialog(
        mission: mission,
        pointsEarned: pointsEarned,
        onContinue: () {
          Navigator.pop(context);
          // Recarregar missões para atualizar pontos
          _loadDailyMissions();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final completedMissions = missions
        .where((m) => m['isCompleted'] == true)
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _isLoading
              ? const DailyMissionsSkeleton()
              : _errorMessage != null
              ? DailyMissionsErrorView(
                  errorMessage: _errorMessage!,
                  onRetry: _loadDailyMissions,
                )
              : BrandedRefreshIndicator(
                  onRefresh: _loadDailyMissions,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        // Header com progresso arredondado
                        DailyMissionsHeader(
                          isSmallScreen: isSmallScreen,
                          earnedPoints: earnedPoints,
                          totalPoints: totalPoints,
                          completedMissions: completedMissions,
                          missions: missions,
                          onBack: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 20),
                        // Lista de missões
                        DailyMissionsList(
                          missions: missions,
                          isSmallScreen: isSmallScreen,
                          onCompleteMission: _completeMission,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
