import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lummy/shared/widgets/widgets.dart';
import 'package:lummy/screens/auth/register_children_screen.dart';
import 'package:lummy/models/responsavel_model.dart';
import 'package:lummy/screens/parent/parent_subscription_screen.dart';
import 'package:lummy/screens/parent/parent_edit_profile_screen.dart';
import 'package:lummy/screens/parent/parent_change_password_screen.dart';
import 'package:lummy/core/utils/app_log.dart';
import 'package:lummy/core/theme/design_tokens.dart';
import 'package:lummy/screens/parent/widgets/profile/parent_profile_account_info_card.dart';
import 'package:lummy/screens/parent/widgets/profile/parent_profile_add_child_card.dart';
import 'package:lummy/screens/parent/widgets/profile/parent_profile_current_plan_card.dart';
import 'package:lummy/screens/parent/widgets/profile/parent_profile_header.dart';
import 'package:lummy/screens/parent/widgets/profile/parent_profile_quick_actions.dart';
import 'package:lummy/screens/parent/widgets/profile/parent_profile_stats_grid.dart';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  State<ParentProfileScreen> createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  String userName = 'Responsável';
  String userEmail = '';
  String? _parentId;
  String? _avatarUrl;
  int childrenCount = 0;
  double totalChildrenBalance = 0.0;
  DateTime? createdAt;
  bool _isLoadingStats = true;

  // Paleta de cores vibrantes
  static const _purple = LummyColors.violet500;
  static const _orange = LummyColors.amber500;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoadingStats = true);

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          userName = 'Responsável';
          _isLoadingStats = false;
        });
        return;
      }

      _parentId = user.id;
      // Fallback: nome do auth (metadata) ou "Responsável" — nunca e-mail
      final meta = user.userMetadata ?? {};
      final nameFallback = (meta['full_name'] ?? meta['name'] ?? meta['username'])?.toString().trim();
      final nameFallbackOrDefault = (nameFallback != null && nameFallback.isNotEmpty) ? nameFallback : 'Responsável';

      // Buscar dados do responsável
      final parentData = await supabase
          .from('responsaveis')
          .select('nome, email, created_at, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      DateTime? loadedCreatedAt;
      if (parentData != null) {
        final nome = (parentData['nome'] as String?)?.trim();
        if (parentData['created_at'] != null) {
          loadedCreatedAt = DateTime.tryParse(parentData['created_at'] as String);
        }
        setState(() {
          userName = (nome != null && nome.isNotEmpty) ? nome : nameFallbackOrDefault;
          userEmail = parentData['email'] as String? ?? user.email ?? '';
          _avatarUrl = parentData['avatar_url'] as String?;
          createdAt = loadedCreatedAt;
        });
      } else {
        setState(() {
          userName = nameFallbackOrDefault;
          userEmail = user.email ?? '';
        });
      }
      // Fallback "Membro desde": usar data de criação do usuário no Auth se a tabela não tiver
      if (createdAt == null) {
        try {
          final authCreated = user.createdAt;
          if (authCreated.isNotEmpty) {
            final parsed = DateTime.tryParse(authCreated);
            if (parsed != null && mounted) {
              setState(() => createdAt = parsed);
            }
          }
        } catch (_) {}
      }

      // Buscar dados dos filhos
      try {
        final childrenData = await supabase
            .from('children')
            .select('id, balance')
            .eq('responsavel_id', user.id);

        double totalBalance = 0.0;
        for (final child in childrenData) {
          totalBalance += (child['balance'] as num?)?.toDouble() ?? 0.0;
        }

        setState(() {
          childrenCount = childrenData.length;
          totalChildrenBalance = totalBalance;
        });
      } catch (e) {
        appLog('Erro ao buscar crianças: $e');
      }
    } catch (e) {
      appLog('Erro ao carregar dados: $e');
      final user = Supabase.instance.client.auth.currentUser;
      if (mounted && user != null) {
        final meta = user.userMetadata ?? {};
        final nameFromMeta = (meta['full_name'] ?? meta['name'] ?? meta['username'])?.toString().trim();
        setState(() {
          userName = (nameFromMeta != null && nameFromMeta.isNotEmpty) ? nameFromMeta : 'Responsável';
          userEmail = user.email ?? '';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingStats) {
      return Scaffold(
        backgroundColor: isDark
            ? LummyColors.darkMaterial
            : LummyColors.slate50,
        body: const Center(child: BrandedLoader(label: 'Carregando perfil...')),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? LummyColors.darkMaterial
          : LummyColors.slate50,
      body: BrandedRefreshIndicator(
        onRefresh: _refreshData,
        color: _purple,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header visual estilo versão infantil
              ParentProfileHeader(
                isDark: isDark,
                userName: userName,
                userEmail: userEmail,
                avatarUrl: _avatarUrl,
                childrenCount: childrenCount,
                totalChildrenBalance: totalChildrenBalance,
                createdAt: createdAt,
                onBack: () => Navigator.pop(context),
              ),
              // Conteúdo principal
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  children: [
                    ParentProfileStatsGrid(
                      isDark: isDark,
                      childrenCount: childrenCount,
                      totalChildrenBalance: totalChildrenBalance,
                    ),
                    const SizedBox(height: 16),
                    ParentProfileCurrentPlanCard(
                      isDark: isDark,
                      onTap: _openSubscription,
                    ),
                    const SizedBox(height: 16),
                    ParentProfileAddChildCard(
                      onTap: _navigateToRegisterChild,
                    ),
                    const SizedBox(height: 16),
                    ParentProfileQuickActions(
                      isDark: isDark,
                      onEditProfile: _openEditProfile,
                      onChangePassword: _openChangePassword,
                    ),
                    const SizedBox(height: 16),
                    ParentProfileAccountInfoCard(
                      isDark: isDark,
                      userEmail: userEmail,
                      createdAt: createdAt,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParentChangePasswordScreen(),
      ),
    );
  }

  void _openSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParentSubscriptionScreen(),
      ),
    );
  }

  void _openEditProfile() {
    if (_parentId == null) {
      _showComingSoon(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParentEditProfileScreen(
          parentId: _parentId!,
          initialName: userName,
          initialEmail: userEmail,
          initialAvatarUrl: _avatarUrl,
        ),
      ),
    ).then((_) => _loadUserData());
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.construction_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Em desenvolvimento',
              style: LummyFonts.body(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: _orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToRegisterChild() {
    if (_parentId == null) {
      _showComingSoon(context);
      return;
    }

    // Criar objeto Responsavel com os dados atuais
    final responsavel = Responsavel(
      nome: userName,
      cpf: '',
      email: userEmail,
      senha: '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterChildrenScreen(
          responsavel: responsavel,
          parentUserId: _parentId!,
        ),
      ),
    ).then((_) {
      // Recarregar dados após voltar da tela de registro
      _loadUserData();
    });
  }

}
