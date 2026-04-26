import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';
import '../../../savings/presentation/providers/branch_provider.dart';



/// Pending verification status page
class PendingPage extends ConsumerWidget {
  const PendingPage({super.key});

  Future<void> _openWhatsApp(
    BuildContext context,
    String email,
    String waNumber,
  ) async {
    final message =
        'Halo Admin KoperasiQu! 👋\n\n'
        'Saya baru saja mendaftarkan diri sebagai anggota KoperasiQu dan sedang menunggu proses verifikasi.\n\n'
        '📧 Email Terdaftar: $email\n\n'
        'Mohon bantuannya untuk mempercepat proses verifikasi akun saya. Terima kasih! 🙏';

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
      if (!launched) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final regState = ref.watch(registrationProvider);
    final branchAsync = ref.watch(branchProvider);

    // Phone/rekening dari API branch
    final waNumber = branchAsync.whenOrNull(
          data: (b) => b.whatsappNumber,
        ) ??
        '';
    final accountNumber = branchAsync.whenOrNull(
          data: (b) => b.bankAccountNumber,
        ) ??
        '—';
    final bankAccountName = branchAsync.whenOrNull(
          data: (b) => b.bankAccountName,
        ) ??
        '—';

    // Email priority: authenticated user > pending user > registration form data
    String email = '';
    if (authState is AuthPending) {
      email = authState.user.email;
    } else if (authState is AuthAuthenticated) {
      email = authState.user.email;
    } else {
      // Came from registration flow — registrationProvider still has data
      email = regState.data.email;
    }

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Hourglass icon with animation
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.warning.withOpacity(0.3),
                          AppColors.warning.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 56,
                      color: AppColors.warning,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 1, end: 1.05, duration: 2.seconds)
                  .then()
                  .animate()
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 32),

              // Status card
              GlassContainer(
                    padding: const EdgeInsets.all(28),
                    borderRadius: 28,
                    child: Column(
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'PENDING',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Menunggu Verifikasi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Pendaftaran Anda sedang dalam proses verifikasi. Kami akan menghubungi Anda dalam 1-2 hari kerja.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // What's next section
              GlassContainer(
                padding: const EdgeInsets.all(20),
                opacity: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apa selanjutnya?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NextStepItem(
                      number: '1',
                      text: 'Tim kami akan mereview dokumen Anda',
                    ),
                    _NextStepItem(
                      number: '2',
                      text: 'Kemungkinan wawancara singkat via WhatsApp',
                    ),
                    _NextStepItem(
                      number: '3',
                      text: 'Notifikasi aktivasi akun akan dikirim',
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Login info card
              if (email.isNotEmpty)
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  opacity: 0.15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.login,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Info Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Anda dapat login dengan:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accentLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Email: $email',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Password: (yang Anda daftarkan)',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 24),

              // Bank account info card
              GlassContainer(
                padding: const EdgeInsets.all(20),
                opacity: 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance,
                          color: Colors.blue.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      const Text(
                        'Rekening Koperasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Simpan nomor rekening ini untuk keperluan setor simpanan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          _BankRow(
                            label: 'Atas Nama',
                            value: bankAccountName,
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.credit_card,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'No. Rekening :',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              branchAsync.isLoading
                                  ? const SizedBox(
                                      width: 120,
                                      height: 16,
                                      child: LinearProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : Text(
                                      accountNumber,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 1.5,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: accountNumber == '—'
                                    ? null
                                    : () {
                                        Clipboard.setData(
                                          ClipboardData(text: accountNumber),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Nomor rekening disalin!',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                child: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 550.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 32),

              // Contact button
              GlassOutlineButton(
                text: 'Hubungi Kami via WhatsApp',
                icon: Icons.chat_bubble_outline,
                onPressed: () => _openWhatsApp(context, email, waNumber),
              ).animate(delay: 600.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 16),

              // Back to home
              TextButton(
                onPressed: () {
                  // Reset registration state to clear step indicator
                  ref.read(registrationProvider.notifier).reset();
                  context.go(Routes.welcome);
                },
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextStepItem extends StatelessWidget {
  const _NextStepItem({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              shape: BoxShape.circle,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
