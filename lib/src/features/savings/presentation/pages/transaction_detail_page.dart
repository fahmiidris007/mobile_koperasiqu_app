import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/wallet_transaction.dart';

/// Halaman detail satu transaksi wallet
class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final statusColor = _statusColor(transaction.status);

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
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Amount card
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 24,
                      opacity: 0.15,
                      child: Column(
                        children: [
                          // Icon
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: (isCredit
                                      ? AppColors.success
                                      : AppColors.expense)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Icon(
                              _getIcon(),
                              color: isCredit
                                  ? AppColors.success
                                  : AppColors.expense,
                              size: 36,
                            ),
                          )
                              .animate()
                              .scale(begin: const Offset(0.7, 0.7))
                              .fadeIn(),

                          const SizedBox(height: 16),

                          Text(
                            transaction.typeLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '${isCredit ? '+' : ''}${transaction.amountFormatted}',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: isCredit
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                              letterSpacing: -1,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: statusColor.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              _statusLabel(transaction.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // Detail info card
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 20,
                      opacity: 0.12,
                      child: Column(
                        children: [
                          _DetailRow(
                            label: 'Tipe Transaksi',
                            value: transaction.typeLabel,
                          ),
                          _divider(),
                          _DetailRow(
                            label: 'Jumlah',
                            value: transaction.amountFormatted,
                          ),
                          if (transaction.serviceFee > 0) ...[
                            _divider(),
                            _DetailRow(
                              label: 'Biaya Layanan',
                              value: transaction.serviceFeeFormatted,
                            ),
                            _divider(),
                            _DetailRow(
                              label: 'Total',
                              value: transaction.totalAmountFormatted,
                              bold: true,
                              valueColor: AppColors.primary,
                            ),
                          ],
                          _divider(),
                          _DetailRow(
                            label: 'Status',
                            value: _statusLabel(transaction.status),
                            valueColor: statusColor,
                            bold: true,
                          ),
                          _divider(),
                          _DetailRow(
                            label: 'Tanggal',
                            value: Formatters.formatDateTime(transaction.createdAt),
                          ),
                          if (transaction.description != null) ...[
                            _divider(),
                            _DetailRow(
                              label: 'Keterangan',
                              value: transaction.description!,
                            ),
                          ],
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 16),

                    // Reference code card (jika ada)
                    if (transaction.referenceCode != null)
                      Builder(
                        builder: (ctx) => GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 16,
                          opacity: 0.12,
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tag_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Kode Referensi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      transaction.referenceCode!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: transaction.referenceCode!,
                                    ),
                                  );
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kode referensi disalin!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.copy,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Salin',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                    // Proof of payment image (jika ada)
                    if (transaction.proofOfPaymentUrl != null) ...[
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        opacity: 0.12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bukti Pembayaran',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                transaction.proofOfPaymentUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120,
                                  color: AppColors.backgroundAlt,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: AppColors.textMuted,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                loadingBuilder: (_, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 120,
                                    color: AppColors.backgroundAlt,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
        color: AppColors.accentLight,
        height: 20,
      );

  IconData _getIcon() {
    switch (transaction.type) {
      case 'topup':
        return Icons.arrow_downward_rounded;
      case 'payment':
        return Icons.shopping_bag_outlined;
      case 'transfer':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.receipt_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.textMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Menunggu';
      default:
        return status.toUpperCase();
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
