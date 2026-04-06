import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/hive_transaction_storage.dart' as hive_tx;
import '../../../savings/presentation/providers/transaction_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final Set<int> _readIds = {};

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);
    final notifications = _buildNotifications(txState.transactions);

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Notifikasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (notifications.any((n) => !_readIds.contains(n.id)))
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _readIds.addAll(notifications.map((n) => n.id));
                        });
                      },
                      child: const Text(
                        'Tandai Semua Dibaca',
                        style: TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: notifications.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final isRead = _readIds.contains(notif.id);
                        return _NotifItem(
                              notif: notif,
                              isRead: isRead,
                              onTap: () {
                                setState(() => _readIds.add(notif.id));
                              },
                            )
                            .animate(delay: (index * 50).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.05, end: 0);
                      },
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<_NotifData> _buildNotifications(
    List<hive_tx.TransactionModel> transactions,
  ) {
    final List<_NotifData> list = [];

    // From real transactions
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      list.add(
        _NotifData(
          id: i,
          icon: tx.isCredit
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
          iconColor: tx.isCredit ? AppColors.success : AppColors.expense,
          title: tx.isCredit ? 'Dana Masuk' : 'Penarikan Dana',
          body:
              '${tx.description} sebesar ${Formatters.formatCurrency(tx.amount)} telah berhasil.',
          time: tx.date,
          type: _NotifType.transaction,
        ),
      );
    }

    // Dummy system notifications
    final now = DateTime.now();
    list.addAll([
      _NotifData(
        id: 9000,
        icon: Icons.verified_rounded,
        iconColor: Colors.blue,
        title: 'Verifikasi Akun',
        body:
            'Akun Anda sedang dalam proses verifikasi oleh tim KoperasiQu. Harap tunggu 1-2 hari kerja.',
        time: now.subtract(const Duration(hours: 2)),
        type: _NotifType.system,
      ),
      _NotifData(
        id: 9001,
        icon: Icons.celebration_rounded,
        iconColor: Colors.orange,
        title: 'Selamat Bergabung! 🎉',
        body:
            'Terima kasih telah mendaftar di KoperasiQu. Nikmati berbagai layanan simpanan dan belanja kami.',
        time: now.subtract(const Duration(days: 1)),
        type: _NotifType.promo,
      ),
      _NotifData(
        id: 9002,
        icon: Icons.local_offer_rounded,
        iconColor: Colors.purple,
        title: 'Promo Spesial',
        body:
            'Dapatkan cashback 5% untuk setiap transaksi belanja di KoperasiQu bulan ini!',
        time: now.subtract(const Duration(days: 2)),
        type: _NotifType.promo,
      ),
    ]);

    list.sort((a, b) => b.time.compareTo(a.time));
    return list;
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppColors.accentLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

enum _NotifType { transaction, system, promo }

class _NotifData {
  const _NotifData({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
  });

  final int id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final DateTime time;
  final _NotifType type;
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({
    required this.notif,
    required this.isRead,
    required this.onTap,
  });

  final _NotifData notif;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        opacity: isRead ? 0.07 : 0.15,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notif.icon, color: notif.iconColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: isRead ? AppColors.textMuted : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _TypeBadge(type: notif.type),
                      const SizedBox(width: 8),
                      Text(
                        _formatRelativeTime(notif.time),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return Formatters.formatDate(dt);
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final _NotifType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      _NotifType.transaction => ('Transaksi', AppColors.success),
      _NotifType.system => ('Sistem', Colors.blue),
      _NotifType.promo => ('Promo', Colors.orange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
