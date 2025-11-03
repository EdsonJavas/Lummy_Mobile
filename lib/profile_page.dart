import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lummy_login/login_page.dart';
import 'package:lummy_login/core/providers/theme_provider.dart';
import 'package:lummy_login/screens/edit_profile_screen.dart';
import 'package:lummy_login/screens/notifications_screen.dart';
import 'package:lummy_login/shared/widgets/cached_avatar.dart';
import 'package:lummy_login/shared/widgets/cached_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String userName = 'Edson Jr';
  final String userRole = 'Pequeno Empreendedor';
  final int userLevel = 5;
  final int totalPoints = 2190;
  final int completedGoals = 8;
  final double totalSaved = 347.50;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 16.0,
          ), // Reduzir padding inferior
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
                    padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsSection(),
                        const SizedBox(height: 20),
                        _buildAchievementsSection(),
                        const SizedBox(height: 20),
                        _buildSettingsSection(),
                        const SizedBox(height: 20), // Reduzido de 100 para 20
                      ],
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
                    child: Text(
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
                        Text(
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Medalhas conquistadas (2)
                    ...List.generate(
                      2,
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

                    const SizedBox(width: 6),

                    // Separador
                    Container(
                      width: 1,
                      height: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),

                    const SizedBox(width: 6),

                    // Medalhas não conquistadas (3)
                    ...List.generate(
                      3,
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
                      '2/5',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildBadge('🥇', 'Primeira\nEconomia', true),
                const SizedBox(width: 16),
                _buildBadge('📊', 'Controle\nde Gastos', true),
                const SizedBox(width: 16),
                _buildBadge('🎯', 'Meta\nAlcançada', false),
                const SizedBox(width: 16),
                _buildBadge('🔥', 'Sequência\n7 dias', false),
                const SizedBox(width: 16),
                _buildBadge('💎', 'Poupador\nEstrela', false),
              ],
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
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
                  activeColor: Colors.white,
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
