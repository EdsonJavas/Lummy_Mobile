import 'package:flutter/material.dart';
import 'package:lummy/core/theme/design_tokens.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;
  bool _goalsNotifications = true;
  bool _achievementsNotifications = true;
  bool _tipsNotifications = true;
  bool _parentMessagesNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Notificações',
          style: LummyFonts.body(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Theme.of(context).brightness == Brightness.dark
                    ? Border.all(color: Theme.of(context).dividerColor)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                          color: LummyColors.violet500.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: LummyColors.violet500,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notificações Gerais',
                              style: LummyFonts.body(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.color,
                              ),
                            ),
                            Text(
                              'Ativar ou desativar todas',
                              style: LummyFonts.body(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                            if (!value) {
                              _goalsNotifications = false;
                              _achievementsNotifications = false;
                              _tipsNotifications = false;
                              _parentMessagesNotifications = false;
                            }
                          });
                        },
                        activeThumbColor: LummyColors.violet500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tipos de notificações
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [LummyColors.violet500, LummyColors.blue500]
                    : [LummyColors.slate800, LummyColors.slate800],
              ).createShader(bounds),
              child: Text(
                'Tipos de Notificações',
                style: LummyFonts.body(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildNotificationOption(
              icon: Icons.flag_outlined,
              title: 'Metas',
              subtitle: 'Avisos sobre progresso das metas',
              color: LummyColors.blue500,
              value: _goalsNotifications,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _goalsNotifications = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            _buildNotificationOption(
              icon: Icons.emoji_events_outlined,
              title: 'Conquistas',
              subtitle: 'Quando você ganhar uma medalha',
              color: LummyColors.amber500,
              value: _achievementsNotifications,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _achievementsNotifications = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            _buildNotificationOption(
              icon: Icons.lightbulb_outline,
              title: 'Dicas Diárias',
              subtitle: 'Receba dicas de educação financeira',
              color: LummyColors.violet500,
              value: _tipsNotifications,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _tipsNotifications = value;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 12),
            _buildNotificationOption(
              icon: Icons.family_restroom,
              title: 'Mensagens dos Pais',
              subtitle: 'Avisos e mensagens importantes',
              color: LummyColors.emerald500,
              value: _parentMessagesNotifications,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() {
                        _parentMessagesNotifications = value;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    final isEnabled = onChanged != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
              ? color.withValues(alpha: 0.2)
              : Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).dividerColor
              : LummyColors.slate200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isEnabled ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isEnabled ? color : LummyColors.slate400,
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
                  style: LummyFonts.body(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? Theme.of(context).textTheme.titleMedium?.color
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: LummyFonts.body(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: color),
        ],
      ),
    );
  }
}
