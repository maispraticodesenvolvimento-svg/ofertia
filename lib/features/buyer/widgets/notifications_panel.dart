import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

/// Abrir o painel de notificações via chave de Scaffold ou Overlay:
///   NotificationsPanel.show(context);
class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  /// Exibe o painel deslizando da direita.
  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fechar notificações',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim, secondaryAnim) =>
          const NotificationsPanel(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: anim.drive(tween), child: child);
      },
    );
  }

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  final _notifications = <_NotifItem>[
    _NotifItem(
      icon: Icons.local_offer_outlined,
      color: AppColors.primary,
      title: 'Nova oferta disponível!',
      body: 'Smartphone Delta X1 com 20% de desconto por tempo limitado.',
      time: 'há 5 min',
      isRead: false,
    ),
    _NotifItem(
      icon: Icons.shopping_cart_outlined,
      color: AppColors.success,
      title: 'Pedido confirmado',
      body: 'Seu pedido #4821 foi confirmado e está sendo preparado.',
      time: 'há 32 min',
      isRead: false,
    ),
    _NotifItem(
      icon: Icons.handshake_outlined,
      color: const Color(0xFF7C3AED),
      title: 'Proposta recebida',
      body: 'Um usuário fez uma proposta para o produto "Cadeira Office".',
      time: 'há 1 hora',
      isRead: false,
    ),
    _NotifItem(
      icon: Icons.star_outline,
      color: const Color(0xFFFFB300),
      title: 'Nova avaliação',
      body: 'Você recebeu uma avaliação 5 estrelas de um comprador.',
      time: 'há 3 horas',
      isRead: true,
    ),
    _NotifItem(
      icon: Icons.inventory_2_outlined,
      color: AppColors.grey500,
      title: 'Produto publicado',
      body: 'Seu produto "Tênis Run Pro" foi publicado com sucesso.',
      time: 'há 1 dia',
      isRead: true,
    ),
    _NotifItem(
      icon: Icons.local_shipping_outlined,
      color: const Color(0xFF0891B2),
      title: 'Pedido enviado',
      body: 'Seu pedido #4715 foi enviado. Previsão: 2 dias úteis.',
      time: 'há 2 dias',
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 380,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(-4, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context),
              if (_unreadCount > 0) _buildUnreadBanner(),
              Expanded(child: _buildList()),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 12,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificações',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount não lidas',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.grey500),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.grey500),
            tooltip: 'Fechar',
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.primary, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você tem $_unreadCount notificações não lidas.',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: _markAllRead,
            child: Text(
              'Marcar todas como lidas',
              style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _notifications.length,
      itemBuilder: (ctx, i) {
        final n = _notifications[i];
        return _NotificationTile(
          item: n,
          onTap: () => setState(() => n.isRead = true),
          onDismiss: () => setState(() => _notifications.removeAt(i)),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _markAllRead,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey700,
                side: const BorderSide(color: AppColors.grey200),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Marcar todas como lidas',
                  style: GoogleFonts.inter(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Ver central',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final _NotifItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withOpacity(0.1),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : AppColors.primarySurface.withOpacity(0.5),
            border: const Border(
                bottom: BorderSide(color: AppColors.grey100)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: item.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.grey900,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.body,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.grey500,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.time,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.grey400),
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
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  bool isRead;

  _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
