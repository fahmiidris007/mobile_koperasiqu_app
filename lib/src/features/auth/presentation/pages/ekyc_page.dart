import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

/// EKYC / Identity verification page with real camera integration
class EkycPage extends ConsumerStatefulWidget {
  const EkycPage({super.key});

  @override
  ConsumerState<EkycPage> createState() => _EkycPageState();
}

class _EkycPageState extends ConsumerState<EkycPage> {
  File? _ktpImage;
  File? _selfieImage;
  bool _isVerifying = false;

  final _picker = ImagePicker();

  // Pick image from camera or gallery
  Future<void> _pickImage({
    required bool isKtp,
    required ImageSource source,
  }) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (picked == null) return;

      setState(() {
        if (isKtp) {
          _ktpImage = File(picked.path);
        } else {
          _selfieImage = File(picked.path);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show bottom sheet to choose camera or gallery
  void _showImageSourceSheet({required bool isKtp}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2B4A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isKtp ? 'Foto KTP' : 'Foto Selfie',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _SourceOption(
              icon: Icons.camera_alt_rounded,
              label: 'Buka Kamera',
              color: AppColors.teal,
              onTap: () {
                Navigator.pop(context);
                _pickImage(isKtp: isKtp, source: ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            _SourceOption(
              icon: Icons.photo_library_rounded,
              label: 'Pilih dari Galeri',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                _pickImage(isKtp: isKtp, source: ImageSource.gallery);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVerification() async {
    if (_ktpImage == null || _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon ambil foto KTP dan Selfie terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Update photo paths in registration data
    final currentData = ref.read(registrationProvider).data;
    ref
        .read(registrationProvider.notifier)
        .updateData(
          currentData.copyWith(
            ktpPhotoPath: _ktpImage!.path,
            selfiePhotoPath: _selfieImage!.path,
          ),
        );

    // Call real POST /register API (multipart with KTP + selfie)
    final user = await ref.read(registrationProvider.notifier).submit();

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (user != null) {
      // Navigate to OTP verification page — email is needed for /otp/verify
      final email = ref.read(registrationProvider).data.email;
      context.pushReplacement(Routes.verifyRegisterOtp, extra: email);
    } else {
      final err = ref.read(registrationProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: Colors.red),
        );
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
                      'Ambil foto KTP dan foto selfie untuk verifikasi identitas Anda',
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

            // KTP upload card
            _PhotoCard(
                  title: 'Foto KTP',
                  subtitle: 'Foto KTP dengan jelas dan tidak buram',
                  icon: Icons.badge_outlined,
                  image: _ktpImage,
                  onTap: () => _showImageSourceSheet(isKtp: true),
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Selfie upload card
            _PhotoCard(
                  title: 'Foto Selfie',
                  subtitle: 'Foto wajah Anda dengan pencahayaan baik',
                  icon: Icons.face_outlined,
                  image: _selfieImage,
                  onTap: () => _showImageSourceSheet(isKtp: false),
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

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Photo card — shows thumbnail if captured, else prompt
// --------------------------------------------------
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.image,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail or placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: hasImage
                  ? Image.file(
                      image!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 160,
                      color: Colors.white.withOpacity(0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 48, color: Colors.white30),
                          const SizedBox(height: 8),
                          Text(
                            'Ketuk untuk mengambil foto',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Footer row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasImage
                          ? Colors.green.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasImage ? Icons.check_rounded : Icons.camera_alt_rounded,
                      color: hasImage ? Colors.green : Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          hasImage ? 'Foto berhasil diambil ✓' : subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasImage
                                ? Colors.green
                                : Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    hasImage ? 'Ubah' : 'Ambil',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Source option button in bottom sheet
// --------------------------------------------------
class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Tip item
// --------------------------------------------------
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
