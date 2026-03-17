import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentNotificationsScreen extends StatefulWidget {
  const ParentNotificationsScreen({super.key});

  static const _prefKeyEnabled = 'parent_notif_enabled';
  static const _prefKeyApprovals = 'parent_notif_approvals';
  static const _prefKeyExpenses = 'parent_notif_expenses';
  static const _prefKeyGoals = 'parent_notif_goals';
  static const _prefKeyTransfers = 'parent_notif_transfers';

  @override
  State<ParentNotificationsScreen> createState() =>
      _ParentNotificationsScreenState();
}

class _ParentNotificationsScreenState extends State<ParentNotificationsScreen> {
  bool _notificationsEnabled = true;
  bool _approvalsNotifications = true;
  bool _expensesNotifications = true;
  bool _goalsNotifications = true;
  bool _transfersNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(ParentNotificationsScreen._prefKeyEnabled) ?? true;
      _approvalsNotifications = prefs.getBool(ParentNotificationsScreen._prefKeyApprovals) ?? true;
      _expensesNotifications = prefs.getBool(ParentNotificationsScreen._prefKeyExpenses) ?? true;
      _goalsNotifications = prefs.getBool(ParentNotificationsScreen._prefKeyGoals) ?? true;
      _transfersNotifications = prefs.getBool(ParentNotificationsScreen._prefKeyTransfers) ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _setEnabled(bool value) {
    setState(() {
      _notificationsEnabled = value;
      if (!value) {
        _approvalsNotifications = false;
        _expensesNotifications = false;
        _goalsNotifications = false;
        _transfersNotifications = false;
      }
    });
    _savePreference(ParentNotificationsScreen._prefKeyEnabled, value);
    if (!value) {
      _savePreference(ParentNotificationsScreen._prefKeyApprovals, false);
      _savePreference(ParentNotificationsScreen._prefKeyExpenses, false);
      _savePreference(ParentNotificationsScreen._prefKeyGoals, false);
      _savePreference(ParentNotificationsScreen._prefKeyTransfers, false);
    }
  }

  void _setApprovals(bool value) {
    setState(() => _approvalsNotifications = value);
    _savePreference(ParentNotificationsScreen._prefKeyApprovals, value);
  }

  void _setExpenses(bool value) {
    setState(() => _expensesNotifications = value);
    _savePreference(ParentNotificationsScreen._prefKeyExpenses, value);
  }

  void _setGoals(bool value) {
    setState(() => _goalsNotifications = value);
    _savePreference(ParentNotificationsScreen._prefKeyGoals, value);
  }

  void _setTransfers(bool value) {
    setState(() => _transfersNotifications = value);
    _savePreference(ParentNotificationsScreen._prefKeyTransfers, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final sectionBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Notificações',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          iconTheme: IconThemeData(color: titleColor),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notificações',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificações in-app',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          'Avisos dentro do app',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: _setEnabled,
                    activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.5),
                    activeThumbColor: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tipos de notificações',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildOption(
              icon: Icons.verified_user_rounded,
              title: 'Aprovações pendentes',
              subtitle: 'Quando um filho pede dinheiro ou faz gasto que exige aprovação',
              color: const Color(0xFF10B981),
              value: _approvalsNotifications,
              onChanged: _notificationsEnabled ? _setApprovals : null,
              isDark: isDark,
              sectionBg: sectionBg,
              borderColor: borderColor,
            ),
            const SizedBox(height: 12),
            _buildOption(
              icon: Icons.receipt_long_rounded,
              title: 'Novos gastos',
              subtitle: 'Quando um filho registra um gasto',
              color: const Color(0xFFF59E0B),
              value: _expensesNotifications,
              onChanged: _notificationsEnabled ? _setExpenses : null,
              isDark: isDark,
              sectionBg: sectionBg,
              borderColor: borderColor,
            ),
            const SizedBox(height: 12),
            _buildOption(
              icon: Icons.flag_rounded,
              title: 'Metas',
              subtitle: 'Progresso e conquistas de metas dos filhos',
              color: const Color(0xFF8B5CF6),
              value: _goalsNotifications,
              onChanged: _notificationsEnabled ? _setGoals : null,
              isDark: isDark,
              sectionBg: sectionBg,
              borderColor: borderColor,
            ),
            const SizedBox(height: 12),
            _buildOption(
              icon: Icons.payments_rounded,
              title: 'Transferências',
              subtitle: 'Confirmação de envio de dinheiro',
              color: const Color(0xFF3B82F6),
              value: _transfersNotifications,
              onChanged: _notificationsEnabled ? _setTransfers : null,
              isDark: isDark,
              sectionBg: sectionBg,
              borderColor: borderColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required void Function(bool)? onChanged,
    required bool isDark,
    required Color sectionBg,
    required Color borderColor,
  }) {
    final enabled = onChanged != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sectionBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? color.withOpacity(0.2) : borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(enabled ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: enabled ? color : const Color(0xFF94A3B8),
              size: 20,
            ),
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
                    color: enabled
                        ? (isDark ? Colors.white : const Color(0xFF1E293B))
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: color.withOpacity(0.5),
            activeThumbColor: color,
          ),
        ],
      ),
    );
  }
}
