import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';

/// Splash screen with animated logo
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash animation then always go to welcome
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.go(Routes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with glass effect
            Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(33),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/koperasiqu.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

            const SizedBox(height: 24),

            // App name
            const Text(
                  'KoperasiQu',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Koperasi Digital untuk Masa Depan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 600.ms),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(
                  Colors.white.withOpacity(0.7),
                ),
              ),
            ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
