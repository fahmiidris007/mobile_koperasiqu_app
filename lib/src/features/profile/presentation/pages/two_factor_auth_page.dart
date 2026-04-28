import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/datasources/user_datasource.dart';
import '../providers/user_provider.dart';

/// Halaman pengaturan Verifikasi Dua Langkah (2FA)
class TwoFactorAuthPage extends ConsumerStatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  ConsumerState<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends ConsumerState<TwoFactorAuthPage> {
  bool? _is2faEnabled;
  bool _isSaving = false;

  Future<void> _toggle2FA(bool newValue) async {
    // Jika mau dimatikan, tampilkan popup konfirmasi
    if (!newValue) {
      final confirmed = await _showDisableConfirmDialog();
      if (!confirmed) return;
    }

    setState(() => _isSaving = true);
    try {
      await UserDatasource().update2FA(enabled: newValue);
      if (!mounted) return;
      setState(() => _is2faEnabled = newValue);
      ref.invalidate(userProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Verifikasi dua langkah diaktifkan'
                : 'Verifikasi dua langkah dinonaktifkan',
          ),
          backgroundColor: newValue ? AppColors.success : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _showDisableConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Matikan Verifikasi Dua Langkah?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Menonaktifkan 2FA membuat akun Anda lebih rentan terhadap akses tidak sah. '
                'Anda tidak akan memerlukan OTP saat login.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.accentLight),
                        ),
                        child: const Center(
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.4),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Matikan',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final is2fa = _is2faEnabled ?? userAsync.valueOrNull?.is2faEnabled ?? true;

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
                      'Verifikasi Dua Langkah',
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
                    // Icon header
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 24),

                    // Penjelasan 2FA
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 20,
                      opacity: 0.12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Apa itu Verifikasi Dua Langkah?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Verifikasi Dua Langkah (2FA) menambahkan lapisan keamanan ekstra '
                            'pada akun Anda. Setiap kali login, Anda akan diminta memasukkan '
                            'kode OTP yang dikirimkan ke email Anda selain password.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Benefits list
                          _BenefitItem(
                            icon: Icons.lock_person_rounded,
                            title: 'Akun lebih aman',
                            subtitle:
                                'Hacker tidak bisa masuk meski tahu password Anda',
                          ),
                          const SizedBox(height: 12),
                          _BenefitItem(
                            icon: Icons.notifications_active_rounded,
                            title: 'Notifikasi akses',
                            subtitle:
                                'Anda tahu setiap ada percobaan login ke akun Anda',
                          ),
                          const SizedBox(height: 12),
                          _BenefitItem(
                            icon: Icons.verified_user_rounded,
                            title: 'Standar keamanan tinggi',
                            subtitle: 'Direkomendasikan untuk akun keuangan',
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // Toggle card
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 20,
                      opacity: 0.12,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: (is2fa
                                          ? AppColors.success
                                          : AppColors.textMuted)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  is2fa
                                      ? Icons.security_rounded
                                      : Icons.no_encryption_rounded,
                                  color: is2fa
                                      ? AppColors.success
                                      : AppColors.textMuted,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Status 2FA',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: Text(
                                        is2fa
                                            ? '✓ Aktif — OTP wajib saat login'
                                            : '✗ Nonaktif — Login langsung tanpa OTP',
                                        key: ValueKey(is2fa),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: is2fa
                                              ? AppColors.success
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Switch(
                                      value: is2fa,
                                      onChanged: _toggle2FA,
                                      activeColor: AppColors.success,
                                      inactiveThumbColor: AppColors.textMuted,
                                    ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Status badge
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 14,
                            ),
                            decoration: BoxDecoration(
                              color: (is2fa
                                      ? AppColors.success
                                      : Colors.orange)
                                  .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (is2fa
                                        ? AppColors.success
                                        : Colors.orange)
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  is2fa
                                      ? Icons.check_circle_outline
                                      : Icons.info_outline,
                                  size: 16,
                                  color: is2fa
                                      ? AppColors.success
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    is2fa
                                        ? 'Akun Anda dilindungi dengan verifikasi dua langkah'
                                        : 'Aktifkan 2FA untuk keamanan akun yang lebih baik',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: is2fa
                                          ? AppColors.success
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

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

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
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
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
