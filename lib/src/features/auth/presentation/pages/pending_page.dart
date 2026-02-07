import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/theme/colors.dart';

/// Pending verification status page
class PendingPage extends StatelessWidget {
  const PendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 2),

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

            const Spacer(flex: 1),

            // Contact button
            GlassOutlineButton(
              text: 'Hubungi Kami',
              icon: Icons.chat_bubble_outline,
              onPressed: () {
                // Open WhatsApp or contact page
              },
            ).animate(delay: 600.ms).fadeIn(duration: 600.ms),

            const SizedBox(height: 16),

            // Back to home
            TextButton(
              onPressed: () => context.go(Routes.welcome),
              child: Text(
                'Kembali ke Beranda',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),

            const SizedBox(height: 40),
          ],
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
