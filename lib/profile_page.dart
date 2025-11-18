import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy_login/login_page.dart';
import 'package:lummy_login/core/providers/theme_provider.dart';
import 'package:lummy_login/screens/edit_profile_screen.dart';
import 'package:lummy_login/screens/notifications_screen.dart';
import 'package:lummy_login/shared/widgets/cached_avatar.dart';
import 'package:lummy_login/shared/widgets/cached_image.dart';
import 'package:lummy_login/shared/widgets/widgets.dart';
import 'package:lummy_login/di/locator.dart';
import 'package:lummy_login/domain/repositories/auth_repository.dart';

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
        debugPrint('🔍 Buscando nome do usuário no perfil: ${user.id}');
        
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
            debugPrint('✅ Nome encontrado na tabela children: $userName');
            return;
          }
        } catch (e) {
          debugPrint('❌ Erro ao buscar na tabela children: $e');
        }

        // Fallback: metadata do usuário
        final meta = user.userMetadata ?? {};
        final name = (meta['name'] ?? meta['full_name'] ?? meta['username']) as String?;
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
      debugPrint('❌ Erro ao carregar nome do usuário: $e');
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
        debugPrint('❌ Usuário não autenticado ao carregar stats');
        setState(() {
          _isLoadingStats = false;
        });
        return;
      }

      debugPrint('📊 Carregando estatísticas do usuário: ${user.id}');

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
          debugPrint('✅ Pontos: $totalPoints, Nível: $userLevel, Saldo: $totalSaved');
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
          debugPrint('⚠️ Dados não encontrados, inicializando com valores padrão');
        }
      } catch (e) {
        // Se der erro (provavelmente colunas não existem), buscar apenas balance
        debugPrint('⚠️ Erro ao buscar pontos/nível (colunas podem não existir): $e');
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
          debugPrint('❌ Erro ao buscar balance: $e2');
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
          debugPrint('✅ ${achievements.length} conquistas encontradas');
        } else {
          setState(() {
            achievements = [];
          });
          debugPrint('ℹ️ Nenhuma conquista encontrada');
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao buscar conquistas: $e');
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
        debugPrint('✅ $completedGoals metas completadas encontradas');
            } catch (e) {
        debugPrint('⚠️ Erro ao buscar metas completadas: $e');
        setState(() {
          completedGoals = 0;
        });
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar estatísticas: $e');
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadUserName(),
      _loadUserStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoadingStats) {
      return Scaffold(
        body: _buildSkeletonLoader(screenWidth, screenHeight),
      );
    }

    return Scaffold(
      body: BrandedRefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 0.0,
            ),
            child: Column(
              children: [
                _buildProfileHeader(screenWidth, screenHeight),
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
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 25,
                          offset: const Offset(0, -15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsSection(),
                          const SizedBox(height: 20),
                          _buildAchievementsSection(),
                          const SizedBox(height: 20),
                          _buildSettingsSection(),
                          const SizedBox(height: 8),
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

  Widget _buildSkeletonLoader(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: screenHeight * 0.60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
            ),
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
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats skeleton
                    const SkeletonText(width: 150, height: 24),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonLoader(
                            width: double.infinity,
                            height: 140,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SkeletonLoader(
                            width: double.infinity,
                            height: 140,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Achievements skeleton
                    const SkeletonText(width: 150, height: 24),
                    const SizedBox(height: 16),
                    SkeletonLoader(
                      width: double.infinity,
                      height: 200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 20),
                    // Settings skeleton
                    const SkeletonText(width: 120, height: 24),
                    const SizedBox(height: 16),
                    ...List.generate(
                      4,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: index == 3 ? 0 : 12),
                        child: SkeletonLoader(
                          width: double.infinity,
                          height: 70,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.60,
      width: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            height: screenHeight * 0.60,
            width: double.infinity,
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Container(
                  decoration: BoxDecoration(
                    image: themeProvider.isDarkMode
                        ? const DecorationImage(
                            image: AssetImage('dark.png'),
                            fit: BoxFit.cover,
                            opacity: 0.8,
                          )
                        : null,
                  ),
                  child: themeProvider.isDarkMode
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.8),
                              ],
                              stops: const [0.0, 0.7, 1.0],
                            ),
                          ),
                        )
                      : CachedImage(
                          imageUrl:
                              'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/fotocriancafodase%201-MFp8K8GLj7deZeGCFVqMJVDVgEtfsc.png',
                          width: double.infinity,
                          height: screenHeight * 0.60,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xFF87CEEB), Color(0xFF4CAF50)],
                              ),
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: 55,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Seu Perfil',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.12,
            left: screenWidth / 2 - 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1E40AF), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const CachedAvatar(
                imageUrl:
                    'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Lum%202-0CkW5uvZjaDxIjCSextrqE198N99r7.png',
                size: 120,
                borderColor: Colors.white,
                borderWidth: 4,
                fallbackIcon: Icons.person,
                fallbackIconColor: Color(0xFF1E40AF),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.27,
            left: screenWidth / 2 - 80,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C42),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoadingStats
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            userLevel.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFF8C42),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        _isLoadingStats
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                totalPoints.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                    Text(
                      'PONTOS TOTAIS',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.36,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    userRole,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF10B981),
                    const Color(0xFF8B5CF6),
                  ] // Verde → Roxo como no site
                : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
          ).createShader(bounds),
          child: Text(
            'Minhas Conquistas',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Metas Concluídas',
                completedGoals.toString(),
                Icons.flag_rounded,
                const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Economizado',
                'R\$ ${totalSaved.toStringAsFixed(0)}',
                Icons.savings_rounded,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: Theme.of(context).dividerColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Esta é a Row que estava causando o overflow
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Adicionado Expanded aqui
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            const Color(0xFFFF8C42),
                            const Color(0xFFEF4444),
                          ] // Laranja → Vermelho como no site
                        : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
                  ).createShader(bounds),
                  child: Text(
                    'Medalhas Conquistadas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow
                        .ellipsis, // Adicionado para evitar overflow de texto
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C42), Color(0xFFFF7A28)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8C42).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final completedCount = achievements.where((a) => a['is_completed'] == true).length;
                    final totalCount = achievements.isNotEmpty ? achievements.length : 5; // Default 5 se não houver conquistas
                    final uncompletedCount = totalCount - completedCount;
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Medalhas conquistadas
                        ...List.generate(
                          completedCount > 5 ? 5 : completedCount,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (completedCount > 0 && uncompletedCount > 0) ...[
                          const SizedBox(width: 6),
                          // Separador
                          Container(
                            width: 1,
                            height: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 6),
                        ],

                        // Medalhas não conquistadas
                        ...List.generate(
                          uncompletedCount > 5 ? 5 : uncompletedCount,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          '$completedCount/$totalCount',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _isLoadingStats
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : achievements.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 48,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma conquista ainda',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Complete missões para desbloquear conquistas!',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: achievements.map((achievement) {
                          final title = achievement['title'] ?? 'Conquista';
                          final emoji = achievement['emoji'] ?? '🏆';
                          final isCompleted = achievement['is_completed'] == true;
                          
                          // Quebrar título em 2 linhas se necessário
                          final titleParts = title.split(' ');
                          String displayTitle;
                          if (titleParts.length > 1) {
                            final mid = (titleParts.length / 2).ceil();
                            displayTitle = '${titleParts.sublist(0, mid).join(' ')}\n${titleParts.sublist(mid).join(' ')}';
                          } else {
                            displayTitle = title;
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildBadge(
                              emoji,
                              displayTitle,
                              isCompleted,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildBadge(String emoji, String label, bool isUnlocked) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isUnlocked
                ? const Color(0xFFFF8C42).withOpacity(0.1)
                : Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFFFF8C42).withOpacity(0.3)
                  : Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(
                fontSize: 24,
                // opacity: isUnlocked ? 1.0 : 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isUnlocked
                ? Theme.of(context).textTheme.titleMedium?.color
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: Theme.of(context).dividerColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFF3B82F6),
                      const Color(0xFF10B981),
                    ] // Azul → Verde como no site
                  : [const Color(0xFF1E293B), const Color(0xFF1E293B)],
            ).createShader(bounds),
            child: Text(
              'Configurações',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            Icons.edit_rounded,
            'Editar Perfil',
            'Altere suas informações pessoais',
            const Color(0xFF1E40AF),
            onTap: () async {
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
            },
          ),
          _buildSettingItem(
            Icons.notifications_rounded,
            'Notificações',
            'Gerencie suas notificações',
            const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          _buildPremiumThemeSettingItem(),
          _buildSettingItem(
            Icons.help_rounded,
            'Ajuda',
            'Tire suas dúvidas',
            const Color(0xFF10B981),
            onTap: () {
              // TODO: Implementar tela de ajuda
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tela de ajuda em desenvolvimento 🚧',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
          _buildSettingItem(
            Icons.logout_rounded,
            'Sair',
            'Desconectar da conta',
            const Color(0xFFEF4444),
            onTap: () async {
              // Mostrar diálogo de confirmação
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Sair da conta?',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    'Tem certeza que deseja sair? Você precisará fazer login novamente.',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Sair',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                try {
                  // Fazer logout no Supabase
                  final authRepo = locator<AuthRepository>();
                  await authRepo.logout();
                  
                  debugPrint('✅ Logout realizado com sucesso');
                  
                  // Navegar para tela de login
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                } catch (e) {
                  debugPrint('❌ Erro ao fazer logout: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro ao fazer logout: $e',
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumThemeSettingItem() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFFF59E0B), // Dourado vibrante
                      const Color(0xFFF97316), // Laranja vibrante
                      const Color(0xFFEF4444), // Vermelho vibrante
                    ]
                  : [
                      const Color(0xFF3B82F6), // Azul vibrante
                      const Color(0xFF8B5CF6), // Roxo vibrante
                      const Color(0xFFEC4899), // Rosa vibrante
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF59E0B).withOpacity(0.4)
                    : const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFF59E0B).withOpacity(0.2)
                    : const Color(0xFF3B82F6).withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: Colors.white,
                    size: 22,
                    key: ValueKey(isDark),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Tema Premium',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDark ? 'Modo escuro ativado' : 'Modo claro ativado',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Switch(
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.4),
                  inactiveThumbColor: Colors.white.withOpacity(0.9),
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
