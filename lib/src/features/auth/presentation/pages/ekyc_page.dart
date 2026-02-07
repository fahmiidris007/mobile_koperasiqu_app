import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../providers/auth_provider.dart';

/// EKYC / Identity verification page (UI simulation)
class EkycPage extends ConsumerStatefulWidget {
  const EkycPage({super.key});

  @override
  ConsumerState<EkycPage> createState() => _EkycPageState();
}

class _EkycPageState extends ConsumerState<EkycPage> {
  bool _ktpUploaded = false;
  bool _selfieUploaded = false;
  bool _isVerifying = false;

  Future<void> _simulateUpload(bool isKtp) async {
    // Simulate image picking and upload
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      if (isKtp) {
        _ktpUploaded = true;
      } else {
        _selfieUploaded = true;
      }
    });
  }

  Future<void> _handleVerification() async {
    if (!_ktpUploaded || !_selfieUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon upload foto KTP dan Selfie'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Simulate EKYC verification
    final success = await ref
        .read(registrationProvider.notifier)
        .verifyEkyc('mock_ktp_path.jpg', 'mock_selfie_path.jpg');

    if (!mounted) return;

    setState(() => _isVerifying = false);

    if (success) {
      // Submit registration
      final user = await ref.read(registrationProvider.notifier).submit();

      if (user != null && mounted) {
        context.go(Routes.pending);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final regState = ref.watch(registrationProvider);

    return GradientBackground(
      animate: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header
            Row(
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
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Verifikasi Identitas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Instructions
            GlassContainer(
              padding: const EdgeInsets.all(16),
              opacity: 0.1,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upload foto KTP dan Selfie untuk verifikasi identitas Anda',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // KTP upload
            _UploadCard(
                  title: 'Foto KTP',
                  subtitle: 'Foto KTP dengan jelas dan tidak buram',
                  icon: Icons.badge_outlined,
                  isUploaded: _ktpUploaded,
                  onTap: () => _simulateUpload(true),
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Selfie upload
            _UploadCard(
                  title: 'Foto Selfie',
                  subtitle: 'Foto wajah Anda dengan pencahayaan baik',
                  icon: Icons.face_outlined,
                  isUploaded: _selfieUploaded,
                  onTap: () => _simulateUpload(false),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Tips
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _TipItem('Pastikan foto jelas dan tidak buram'),
                  _TipItem('Hindari pantulan cahaya pada KTP'),
                  _TipItem('Pastikan wajah terlihat dengan jelas'),
                  _TipItem('Gunakan pencahayaan yang baik'),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // Verify button
            GlassButton(
              text: 'Verifikasi Sekarang',
              icon: Icons.verified_user,
              isLoading: _isVerifying || regState.isLoading,
              onPressed: _handleVerification,
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 16),

            // VIDA branding
            Text(
              'Powered by VIDA',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isUploaded,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isUploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUploaded
                  ? Colors.green.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUploaded
                    ? Colors.green
                    : Colors.white.withOpacity(0.3),
                style: isUploaded ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: Icon(
              isUploaded ? Icons.check : icon,
              color: isUploaded ? Colors.green : Colors.white70,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUploaded ? 'Berhasil diupload ✓' : subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isUploaded
                        ? Colors.green
                        : Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!isUploaded)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.blue, size: 20),
            ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
