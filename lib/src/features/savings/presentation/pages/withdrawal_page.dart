import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';

/// Withdrawal page — fitur masih dalam pengembangan
class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  @override
  void initState() {
    super.initState();
    // Tampilkan dialog segera setelah halaman terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showComingSoonDialog();
    });
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ComingSoonDialog(),
    ).then((_) {
      // Kembali ke halaman sebelumnya setelah dialog ditutup
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleGradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header minimal
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
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Penarikan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Placeholder content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        color: Colors.orange,
                        size: 52,
                      ),
                    ).animate().scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Fitur Dalam Pengembangan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Fitur penarikan sedang dalam\nproses pengembangan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
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

/// Dialog "Coming Soon"
class _ComingSoonDialog extends StatelessWidget {
  const _ComingSoonDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(28),
        borderRadius: 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms),

            const SizedBox(height: 24),

            const Text(
              'Segera Hadir!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 12),

            Text(
              'Fitur penarikan dana saat ini masih dalam tahap pengembangan. Kami akan segera menghadirkannya untuk Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
            ).animate(delay: 250.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 8),

            // Badge
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.orange),
                  SizedBox(width: 6),
                  Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 350.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 28),

            GlassButton(
              text: 'Mengerti',
              onPressed: () => Navigator.of(context).pop(),
            ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
