import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/ensure_child_record.dart';

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
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
        throw Exception('Não foi possível criar o registro do usuário. Verifique se você foi registrado por um responsável.');
      }

      debugPrint('📅 Carregando missões diárias para usuário: ${user.id}');

      // Chamar função para selecionar/buscar missões do dia
      final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
      
      final result = await supabase.rpc(
        'select_daily_missions',
        params: {
          'p_child_id': user.id,
          'p_selected_date': today,
        },
      );

      debugPrint('✅ Resultado da função: $result');

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

        debugPrint('✅ ${missions.length} missões carregadas');
      } else {
        // Se não retornou missões, pode ser que a função não exista ainda
        // Tentar buscar diretamente
        debugPrint('⚠️ Função não retornou missões, tentando busca direta...');
        await _loadMissionsDirectly(user.id, today);
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar missões: $e');
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
        final missionIds = existingMissions.map((m) => m['mission_id'] as String).toList();
        
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
      debugPrint('❌ Erro ao carregar missões diretamente: $e');
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
      debugPrint('❌ Erro ao selecionar missões aleatórias: $e');
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
        throw Exception('Não foi possível criar o registro do usuário. Verifique se você foi registrado por um responsável.');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Tentar usar a função do banco
      try {
        final result = await supabase.rpc(
          'complete_daily_mission',
          params: {
            'p_child_id': user.id,
            'p_mission_id': missionId,
            'p_selected_date': today,
          },
        ).single();

        final pointsEarned = result['points_earned'] as int;
        final newTotalPoints = result['new_total_points'] as int;
        final newLevel = result['new_level'] as int;

        debugPrint('✅ Missão concluída! Pontos: $pointsEarned, Total: $newTotalPoints, Nível: $newLevel');

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
        debugPrint('⚠️ Função não disponível, atualizando manualmente: $e');
        await _completeMissionManually(missionId, user.id, today);
      }
    } catch (e) {
      debugPrint('❌ Erro ao completar missão: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao completar missão: $e',
            style: GoogleFonts.poppins(),
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

  Future<void> _completeMissionManually(String missionId, String userId, String today) async {
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
      final currentLevel = (childData['level'] as int?) ?? 1;
      
      final newPoints = currentPoints + points;
      final newLevel = (newPoints / 1000).floor() + 1; // Nível sobe a cada 1000 pontos

      // Atualizar pontos e nível
      await supabase
          .from('children')
          .update({
            'total_points': newPoints,
            'level': newLevel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      debugPrint('✅ Missão concluída! Pontos: $points, Total: $newPoints, Nível: $newLevel');

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
      debugPrint('❌ Erro ao completar missão manualmente: $e');
      rethrow;
    }
  }

  void _showCompletionDialog(String missionId, int pointsEarned) {
    final mission = missions.firstWhere((m) => m['id'] == missionId);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Theme.of(context).brightness == Brightness.dark
                ? Border.all(color: Theme.of(context).dividerColor, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji em círculo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (mission['color'] as Color).withOpacity(0.2),
                      (mission['color'] as Color).withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (mission['color'] as Color).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  mission['emoji'] as String,
                  style: const TextStyle(fontSize: 56),
                ),
              ),
              const SizedBox(height: 24),
              // Título
              Text(
                'Missão Completa!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Nome da missão
              Text(
                mission['title'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Pontos ganhos
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (mission['color'] as Color).withOpacity(0.15),
                      (mission['color'] as Color).withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (mission['color'] as Color).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '+$pointsEarned pontos',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: mission['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Botão
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Recarregar missões para atualizar pontos
                    _loadDailyMissions();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mission['color'] as Color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continuar',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.poppins(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadDailyMissions,
                              child: const Text('Tentar Novamente'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Header com progresso arredondado
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: Theme.of(context).brightness == Brightness.dark
                                    ? [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)]
                                    : [const Color(0xFF1E40AF), const Color(0xFF1E3A8A)],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(
                              isSmallScreen ? 20.0 : 24.0,
                              MediaQuery.of(context).padding.top + 16,
                              isSmallScreen ? 20.0 : 24.0,
                              isSmallScreen ? 20.0 : 24.0,
                            ),
                            child: Column(
                              children: [
                                // Botão voltar e título
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Missões Diárias',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 48), // Para centralizar o título
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Seu Progresso',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              earnedPoints.toString(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              ' / $totalPoints',
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pontos hoje',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '$completedMissions/${missions.length}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Completas',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
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
                                // Barra de progresso melhorada
                                missions.isEmpty
                                    ? const SizedBox.shrink()
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Progresso Diário',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white.withOpacity(0.9),
                                                ),
                                              ),
                                              Text(
                                                missions.isEmpty
                                                    ? '0%'
                                                    : '${((completedMissions / missions.length) * 100).toStringAsFixed(0)}%',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: missions.isEmpty
                                                    ? 0.0
                                                    : (completedMissions / missions.length)
                                                        .clamp(0.0, 1.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      colors: [
                                                        Color(0xFF10B981),
                                                        Color(0xFF34D399),
                                                        Color(0xFF6EE7B7),
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(0xFF10B981)
                                                            .withOpacity(0.5),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 0),
                                                      ),
                                                    ],
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
                          const SizedBox(height: 20),
                          // Lista de missões
                          missions.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.assignment_outlined,
                                        size: 64,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhuma missão disponível',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'As missões diárias aparecerão aqui!',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 16.0 : 20.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => LinearGradient(
                                          colors: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? [
                                                  const Color(0xFF3B82F6),
                                                  const Color(0xFF8B5CF6),
                                                ] // Azul → Roxo
                                              : [
                                                  const Color(0xFF1E293B),
                                                  const Color(0xFF1E293B),
                                                ],
                                        ).createShader(bounds),
                                        child: Text(
                                          'Missões de Hoje',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ...missions.map(
                                        (mission) => Padding(
                                          padding: const EdgeInsets.only(bottom: 16),
                                          child: _buildMissionCard(mission, isSmallScreen),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission, bool isSmallScreen) {
    final progress = mission['progress'] as int;
    final total = mission['total'] as int;
    final isCompleted = mission['isCompleted'] as bool;
    final progressPercent = total > 0 ? (progress / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? (mission['color'] as Color).withOpacity(0.3)
              : Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).dividerColor
              : const Color(0xFFE2E8F0),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (mission['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    mission['emoji'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission['description'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (mission['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${mission['points']}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: mission['color'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progresso
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).dividerColor
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: mission['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progress/$total',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _completeMission(mission['id'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mission['color'] as Color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Completar Missão',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          if (isCompleted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Missão Concluída!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
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
    );
  }
}
