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

/// Dummy bank account info
class _BankInfo {
  static const String accountNumber = '1234-5678-9012-3456';
  static const String waNumber = '62895627540107';
}

/// Pending verification status page
class PendingPage extends ConsumerWidget {
  const PendingPage({super.key});

  Future<void> _openWhatsApp(BuildContext context, String email) async {
    final message =
        'Halo Admin KoperasiQu! 👋\n\n'
        'Saya baru saja mendaftarkan diri sebagai anggota KoperasiQu dan sedang menunggu proses verifikasi.\n\n'
        '📧 Email Terdaftar: $email\n\n'
        'Mohon bantuannya untuk mempercepat proses verifikasi akun saya. Terima kasih! 🙏';

    final encoded = Uri.encodeComponent(message);
    final appUrl = Uri.parse(
      'whatsapp://send?phone=${_BankInfo.waNumber}&text=$encoded',
    );
    final webUrl = Uri.parse(
      'https://wa.me/${_BankInfo.waNumber}?text=$encoded',
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

    // Email priority: authenticated user > pending user > registration form data
    String email = '';
    String fullName = '';
    if (authState is AuthPending) {
      email = authState.user.email;
      fullName = authState.user.name;
    } else if (authState is AuthAuthenticated) {
      email = authState.user.email;
      fullName = authState.user.name;
    } else {
      // Came from registration flow — registrationProvider still has data
      email = regState.data.email;
      fullName = regState.data.fullName;
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
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Pendaftaran Anda sedang dalam proses verifikasi. Kami akan menghubungi Anda dalam 1-2 hari kerja.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
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
                        color: Colors.white,
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
                            color: Colors.green.shade300,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Info Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Anda dapat login dengan:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.email_outlined,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Email: $email',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Password: (yang Anda daftarkan)',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
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
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Simpan nomor rekening ini untuk keperluan setor simpanan.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        children: [
                          _BankRow(
                            label: 'Atas Nama',
                            value: fullName.isNotEmpty ? fullName : 'Anggota',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.credit_card,
                                size: 16,
                                color: Colors.white54,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'No. Rekening :',
                                  style: TextStyle(
                                    color: Colors.white54,
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
                              Text(
                                _BankInfo.accountNumber,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    const ClipboardData(
                                      text: _BankInfo.accountNumber,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nomor rekening disalin!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: AppColors.teal,
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
                onPressed: () => _openWhatsApp(context, email),
              ).animate(delay: 600.ms).fadeIn(duration: 600.ms),

              const SizedBox(height: 16),

              // Back to home
              TextButton(
                onPressed: () {
                  // Reset registration state to clear step indicator
                  ref.read(registrationProvider.notifier).reset();
                  context.go(Routes.welcome);
                },
                child: Text(
                  'Kembali ke Beranda',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
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
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.blue,
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
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
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
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
