import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/theme/colors.dart';
import '../providers/branch_provider.dart';


// ── Page ─────────────────────────────────────────────────────────────────────

/// Halaman penarikan dana — mengarahkan user untuk datang ke cabang
class WithdrawalPage extends ConsumerWidget {
  const WithdrawalPage({super.key});

  Future<void> _openWhatsApp(BuildContext context, String waNumber) async {
    const message =
        'Halo Admin KoperasiQu! 👋\n\n'
        'Saya ingin melakukan penarikan dana tabungan. '
        'Mohon informasi lebih lanjut mengenai prosedur penarikan. Terima kasih 🙏';

    final encoded = Uri.encodeComponent(message);
    final appUrl = Uri.parse(
      'whatsapp://send?phone=$waNumber&text=$encoded',
    );
    final webUrl = Uri.parse(
      'https://wa.me/$waNumber?text=$encoded',
    );

    try {
      final launched = await launchUrl(
        appUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched)
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka WhatsApp.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _callBranch(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat melakukan panggilan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchAsync = ref.watch(branchProvider);
    final waNumber = branchAsync.whenOrNull(data: (b) => b.whatsappNumber) ?? '';
    final phone = branchAsync.whenOrNull(data: (b) => b.phoneNumber) ?? '—';
    final branchName = branchAsync.whenOrNull(data: (b) => b.name) ?? 'Kantor Cabang KoperasiQu';

    return SimpleGradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Penarikan Dana',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // ── Hero icon + judul ────────────────────────────────────
                    Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: AppColors.primary,
                            size: 48,
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 300.ms),

                    const SizedBox(height: 20),

                    const Text(
                      'Penarikan Melalui Cabang',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 8),

                    const Text(
                      'Silakan datang ke kantor cabang KoperasiQu terdekat untuk melakukan penarikan dana tabungan Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 28),

                    // ── Card: Info Cabang ─────────────────────────────────────
                    GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: 20,
                          opacity: 0.12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Kantor Cabang',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _InfoTile(
                                icon: Icons.place_outlined,
                                label: 'Kantor Cabang',
                                value: branchName,
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: branchName),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nama cabang disalin!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                tapLabel: 'Salin',
                              ),
                              const Divider(color: AppColors.accentLight, height: 20),
                              _InfoTile(
                                icon: Icons.access_time_rounded,
                                label: 'Jam Operasional',
                                value: 'Senin – Jumat, 08.00 – 16.00 WIB',
                              ),
                              const Divider(color: AppColors.accentLight, height: 20),
                              _InfoTile(
                                icon: Icons.phone_outlined,
                                label: 'Telepon',
                                value: branchAsync.isLoading ? 'Memuat...' : phone,
                                onTap: phone == '—' ? null : () => _callBranch(context, phone),
                                tapLabel: 'Hubungi',
                              ),
                            ],
                          ),
                        )
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),

                    const SizedBox(height: 20),

                    // ── Card: Prosedur ────────────────────────────────────────
                    GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: 20,
                          opacity: 0.10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.checklist_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Prosedur Penarikan',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _StepItem(
                                number: '1',
                                text:
                                    'Bawa KTP/identitas diri yang masih berlaku',
                              ),
                              _StepItem(
                                number: '2',
                                text:
                                    'Datang ke kantor cabang pada jam operasional',
                              ),
                              _StepItem(
                                number: '3',
                                text:
                                    'Ambil nomor antrian dan isi formulir penarikan',
                              ),
                              _StepItem(
                                number: '4',
                                text:
                                    'Petugas akan memverifikasi data dan memproses penarikan',
                                isLast: true,
                              ),
                            ],
                          ),
                        )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),

                    const SizedBox(height: 20),

                    // ── Note ─────────────────────────────────────────────────
                    GlassContainer(
                      padding: const EdgeInsets.all(14),
                      borderRadius: 14,
                      opacity: 0.07,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: const Text(
                              'Jika ada pertanyaan sebelum datang ke cabang, '
                              'Anda dapat menghubungi admin kami melalui WhatsApp di bawah ini.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 28),

                    // ── Tombol WhatsApp ───────────────────────────────────────
                    GlassButton(
                      text: 'Tanya via WhatsApp',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: waNumber.isEmpty
                          ? null
                          : () => _openWhatsApp(context, waNumber),
                    ).animate(delay: 450.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

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
}

// ── Info Tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.tapLabel,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final String? tapLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null && tapLabel != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tapLabel!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Step Item ─────────────────────────────────────────────────────────────────

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.text,
    this.isLast = false,
  });

  final String number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (!isLast) Container(width: 1, height: 28, color: AppColors.accentLight),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
