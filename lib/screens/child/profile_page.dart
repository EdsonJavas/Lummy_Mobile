import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy/core/constants/app_constants.dart';
import 'package:lummy/screens/child/edit_profile_screen.dart';
import 'package:lummy/screens/child/flows/child_logout_flow.dart';
import 'package:lummy/screens/child/notifications_screen.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/child/widgets/profile/profile_achievements_section.dart';
import 'package:lummy/screens/child/widgets/profile/profile_header.dart';
import 'package:lummy/screens/child/widgets/profile/profile_settings_section.dart';
import 'package:lummy/screens/child/widgets/profile/profile_skeleton_loader.dart';
import 'package:lummy/screens/child/widgets/profile/profile_stats_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Carregando...';
  final String userRole = 'Pequeno Empreendedor';
  int userLevel = 1;
  int totalPoints = 0;
  int completedGoals = 0;
  double totalSaved = 0.0;
  List<Map<String, dynamic>> achievements = [];
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadUserStats();
  }

  Future<void> _loadUserName() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {

        // Buscar na tabela children
        try {
          final childRow = await supabase
              .from('children')
              .select('nome')
              .eq('id', user.id)
              .maybeSingle();

          if (childRow != null && childRow['nome'] != null) {
            setState(() {
              userName = childRow['nome'] as String;
            });
            return;
          }
        } catch (e) {
          appLog('❌ Erro ao buscar na tabela children: $e');
        }

        // Fallback: metadata do usuário
        final meta = user.userMetadata ?? {};
        final name =
            (meta['name'] ?? meta['full_name'] ?? meta['username']) as String?;
        if (name != null && name.trim().isNotEmpty) {
          setState(() {
            userName = name.trim();
          });
          return;
        }

        // Fallback: prefixo do email
        final emailName = user.email?.split('@').first;
        if (emailName != null && emailName.trim().isNotEmpty) {
          setState(() {
            userName = emailName.trim();
          });
          return;
        }
      }

      setState(() {
        userName = 'Usuário';
      });
    } catch (e) {
      appLog('❌ Erro ao carregar nome do usuário: $e');
      setState(() {
        userName = 'Usuário';
      });
    }
  }

  Future<void> _loadUserStats() async {
    try {
      setState(() {
        _isLoadingStats = true;
      });

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        appLog('❌ Usuário não autenticado ao carregar stats');
        setState(() {
          _isLoadingStats = false;
        });
        return;
      }


      // 1. Buscar pontos e nível da tabela children
      try {
        // Primeiro tentar buscar com as novas colunas
        final childData = await supabase
            .from('children')
            .select('total_points, level, balance')
            .eq('id', user.id)
            .maybeSingle();

        if (childData != null) {
          setState(() {
            // Se as colunas não existirem ainda, usar valores padrão
            totalPoints = (childData['total_points'] as int?) ?? 0;
            userLevel = (childData['level'] as int?) ?? 1;
            totalSaved = (childData['balance'] as num?)?.toDouble() ?? 0.0;
          });
        } else {
          // Se não encontrar dados, buscar apenas balance e inicializar resto
          final balanceData = await supabase
              .from('children')
              .select('balance')
              .eq('id', user.id)
              .maybeSingle();

          setState(() {
            totalPoints = 0;
            userLevel = 1;
            totalSaved = (balanceData?['balance'] as num?)?.toDouble() ?? 0.0;
          });
          appLog(
            '⚠️ Dados não encontrados, inicializando com valores padrão',
          );
        }
      } catch (e) {
        // Se der erro (provavelmente colunas não existem), buscar apenas balance
        appLog(
          '⚠️ Erro ao buscar pontos/nível (colunas podem não existir): $e',
        );
        try {
          final balanceData = await supabase
              .from('children')
              .select('balance')
              .eq('id', user.id)
              .maybeSingle();

          setState(() {
            totalPoints = 0;
            userLevel = 1;
            totalSaved = (balanceData?['balance'] as num?)?.toDouble() ?? 0.0;
          });
        } catch (e2) {
          appLog('❌ Erro ao buscar balance: $e2');
          setState(() {
            totalPoints = 0;
            userLevel = 1;
            totalSaved = 0.0;
          });
        }
      }

      // 2. Buscar conquistas da tabela achievements
      try {
        final achievementsData = await supabase
            .from('achievements')
            .select('*')
            .eq('child_id', user.id)
            .order('completed_date', ascending: false);

        if (achievementsData.isNotEmpty) {
          setState(() {
            achievements = List<Map<String, dynamic>>.from(achievementsData);
          });
        } else {
          setState(() {
            achievements = [];
          });
        }
      } catch (e) {
        appLog('⚠️ Erro ao buscar conquistas: $e');
        setState(() {
          achievements = [];
        });
      }

      // 3. Buscar metas completadas da tabela goals
      try {
        final completedGoalsData = await supabase
            .from('goals')
            .select('id')
            .eq('child_id', user.id)
            .eq('status', 'completed');

        setState(() {
          completedGoals = completedGoalsData.length;
        });
      } catch (e) {
        appLog('⚠️ Erro ao buscar metas completadas: $e');
        setState(() {
          completedGoals = 0;
        });
      }
    } catch (e) {
      appLog('❌ Erro ao carregar estatísticas: $e');
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([_loadUserName(), _loadUserStats()]);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoadingStats) {
      return Scaffold(body: ProfileSkeletonLoader(screenHeight: screenHeight));
    }

    return Scaffold(
      body: BrandedRefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0.0),
            child: Column(
              children: [
                ProfileHeader(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isLoadingStats: _isLoadingStats,
                  userLevel: userLevel,
                  totalPoints: totalPoints,
                  userName: userName,
                  userRole: userRole,
                  onBack: () => Navigator.pop(context),
                ),
                Transform(
                  transform: Matrix4.translationValues(0, -40, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 25,
                          offset: const Offset(0, -15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spacingLarge,
                        50.0,
                        AppConstants.spacingLarge,
                        0.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileStatsSection(
                            completedGoals: completedGoals,
                            totalSaved: totalSaved,
                          ),
                          const Gap(20),
                          ProfileAchievementsSection(
                            isLoadingStats: _isLoadingStats,
                            achievements: achievements,
                          ),
                          const Gap(20),
                          ProfileSettingsSection(
                            onEditProfileTap: _onEditProfileTap,
                            onNotificationsTap: _onNotificationsTap,
                            onHelpTap: _onHelpTap,
                            onLogoutTap: _onLogoutTap,
                          ),
                          const Gap(8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onEditProfileTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    // Se houve atualização, recarregar o nome
    if (result == true) {
      _loadUserName();
    }
  }

  void _onNotificationsTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _onHelpTap() {
    // TODO: Implementar tela de ajuda
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tela de ajuda em desenvolvimento 🚧',
          style: LummyFonts.body(fontWeight: FontWeight.w500),
        ),
        backgroundColor: LummyColors.emerald500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Mesmo fluxo do menu lateral: confirma, sai e zera a cor e o perfil da
  /// criança.
  Future<void> _onLogoutTap() => sairDaContaCrianca(context);
}
