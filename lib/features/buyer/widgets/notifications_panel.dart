import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_client.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar notificações',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => const NotificationsPanel(),
      transitionBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(animation),
        child: child,
      ),
    );
  }

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  late Future<List<Map<String, dynamic>>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = ApiClient().getNotifications();
  }

  void _reload() => setState(() => _notifications = ApiClient().getNotifications());

  Future<void> _markRead(String id) async {
    try {
      await ApiClient().markNotificationRead(id);
      _reload();
    } catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  Future<void> _delete(String id) async {
    try {
      await ApiClient().deleteNotification(id);
      _reload();
    } catch (error) {
      if (mounted) _message(error.toString());
    }
  }

  void _message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.white,
          child: SizedBox(
            width: 380,
            height: double.infinity,
            child: Column(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 14, 12, 14),
                child: Row(children: [
                  const Icon(Icons.notifications_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Notificações', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16))),
                  IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ]),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _notifications,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return _empty(snapshot.error.toString(), Icons.cloud_off_outlined);
                    final items = snapshot.data ?? const <Map<String, dynamic>>[];
                    if (items.isEmpty) return _empty('Nenhuma notificação.', Icons.notifications_none);
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final id = item['id'].toString();
                        final read = item['read'] == true;
                        return Dismissible(
                          key: ValueKey(id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _delete(id),
                          background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: AppColors.error.withValues(alpha: 0.1), child: const Icon(Icons.delete_outline, color: AppColors.error)),
                          child: ListTile(
                            tileColor: read ? Colors.white : AppColors.primarySurface.withValues(alpha: 0.5),
                            leading: Icon(read ? Icons.notifications_none : Icons.notifications_active_outlined, color: AppColors.primary),
                            title: Text(item['title']?.toString() ?? '', style: GoogleFonts.inter(fontWeight: read ? FontWeight.w500 : FontWeight.w700, fontSize: 13)),
                            subtitle: Text(item['body']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey600)),
                            onTap: read ? null : () => _markRead(id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      );

  Widget _empty(String text, IconData icon) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 38, color: AppColors.grey400),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.grey600)),
          ]),
        ),
      );
}
