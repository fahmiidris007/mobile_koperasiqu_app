import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../data/datasources/wallet_datasource.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../providers/branch_provider.dart';
import '../providers/wallet_provider.dart';

// ── Page ─────────────────────────────────────────────────────────────────────

/// Halaman upload bukti transfer — langkah kedua flow top up.
/// Menerima [amount] (int, dalam rupiah) dari GoRouter extra.
class UploadPaymentProofPage extends ConsumerStatefulWidget {
  const UploadPaymentProofPage({super.key, required this.amount});

  /// Nominal top up (tanpa kode unik) dalam satuan rupiah.
  final int amount;

  @override
  ConsumerState<UploadPaymentProofPage> createState() =>
      _UploadPaymentProofPageState();
}

class _UploadPaymentProofPageState
    extends ConsumerState<UploadPaymentProofPage> {
  File? _proofImage;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
      );
      if (picked == null) return;
      setState(() => _proofImage = File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageSourceSheet(onPick: _pickImage),
    );
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);

    try {
      // Step 1: POST /wallet/topup — buat permintaan topup, dapatkan ID
      final result = await ref
          .read(topupNotifierProvider.notifier)
          .topup(amount: widget.amount.toDouble());

      if (!mounted) return;

      if (result == null) {
        final error = ref.read(topupNotifierProvider).error;
        await showDialog<void>(
          context: context,
          builder: (ctx) => _TopupResultDialog(
            errorMessage: error ?? 'Gagal melakukan top up',
            isSuccess: false,
          ),
        );
        return;
      }

      // Step 2: upload bukti langsung via datasource (bypass autoDispose provider)
      // Ini menghindari "Bad state: after dispose" karena upload adalah one-shot
      if (_proofImage != null) {
        try {
          await WalletDatasource().uploadTopupProof(
            topupId: result.id,
            imagePath: _proofImage!.path,
          );
          // Refresh wallet data setelah upload
          ref.invalidate(walletProvider);
          ref.invalidate(walletTransactionsProvider);
        } catch (uploadErr) {
          log('upload proof warning (topup tetap sukses): $uploadErr');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Topup berhasil, namun gagal upload bukti'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Topup tetap berhasil, lanjut ke dialog sukses
        }
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _TopupResultDialog(result: result, isSuccess: true),
      );
      if (!mounted) return;
      context.go(Routes.savings);
    } catch (e) {
      log('error topup proof: $e');
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => _TopupResultDialog(
            errorMessage: 'Terjadi kesalahan: $e',
            isSuccess: false,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep provider alive
    ref.watch(topupNotifierProvider);
    final branchAsync = ref.watch(branchProvider);

    final amountFormatted = Formatters.formatCurrency(widget.amount);

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
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Upload Bukti Transfer',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Step indicator
                    _StepIndicator(),

                    const SizedBox(height: 24),

                    // ── Card: Instruksi Transfer ─────────────────────────────
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_balance,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Transfer ke Rekening Berikut',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Info rekening
                          _InfoRow(
                            label: 'Bank',
                            value:
                                branchAsync.whenOrNull(
                                  data: (b) => b.bankName,
                                ) ??
                                '—',
                            icon: Icons.domain,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Atas Nama',
                            value:
                                branchAsync.whenOrNull(
                                  data: (b) => b.bankAccountName,
                                ) ??
                                '—',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),

                          // Nomor rekening + copy
                          Builder(
                            builder: (context) {
                              final accountNumber =
                                  branchAsync.whenOrNull(
                                    data: (b) => b.bankAccountNumber,
                                  ) ??
                                  '—';
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.credit_card,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'No. Rekening',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        branchAsync.isLoading
                                            ? const SizedBox(
                                                width: 120,
                                                height: 18,
                                                child: LinearProgressIndicator(
                                                  color: AppColors.primary,
                                                ),
                                              )
                                            : Text(
                                                accountNumber,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: accountNumber == '—'
                                        ? null
                                        : () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: accountNumber,
                                              ),
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
                                      size: 20,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Divider
                          const Divider(color: AppColors.accentLight),

                          const SizedBox(height: 16),

                          // Nominal transfer
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jumlah Transfer',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      amountFormatted,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: widget.amount.toString(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Nominal disalin!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.copy,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Salin',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Card: Upload Bukti ────────────────────────────────────
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.upload_file,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Bukti Transfer',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Opsional',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Preview atau placeholder
                          if (_proofImage != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _proofImage!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: _showImageSourceSheet,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Ganti foto',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            GestureDetector(
                              onTap: _showImageSourceSheet,
                              child: Container(
                                width: double.infinity,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundAlt,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.accentLight,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: AppColors.accentLight,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Tap untuk upload foto bukti transfer',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Foto dari galeri atau kamera',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 16),

                    // Info note
                    GlassContainer(
                      padding: const EdgeInsets.all(14),
                      opacity: 0.07,
                      borderRadius: 14,
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
                              'Pastikan nominal transfer sesuai dengan jumlah di atas. '
                              'Top up akan diproses oleh admin setelah verifikasi.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    // ── Tombol Konfirmasi ─────────────────────────────────────
                    GlassButton(
                      text: 'Konfirmasi Top Up',
                      icon: Icons.check_circle_outline,
                      isLoading: _isSubmitting,
                      onPressed: _handleConfirm,
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 40),
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

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stepCircle(label: '1', title: 'Nominal', done: true),
        _stepLine(),
        _stepCircle(label: '2', title: 'Transfer & Bukti', active: true),
      ],
    );
  }

  Widget _stepCircle({
    required String label,
    required String title,
    bool done = false,
    bool active = false,
  }) {
    final bg = done
        ? AppColors.success
        : active
        ? AppColors.primary
        : AppColors.accentLight;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _stepLine() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success, AppColors.primary],
          ),
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Image Source Bottom Sheet ─────────────────────────────────────────────────

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet({required this.onPick});

  final Future<void> Function(ImageSource) onPick;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pilih Sumber Foto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    onPick(ImageSource.gallery);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Kamera',
                  onTap: () {
                    Navigator.pop(context);
                    onPick(ImageSource.camera);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result Dialog ─────────────────────────────────────────────────────────────

class _TopupResultDialog extends StatelessWidget {
  const _TopupResultDialog({
    this.result,
    this.errorMessage,
    required this.isSuccess,
  });

  final TopupResult? result;
  final String? errorMessage;
  final bool isSuccess;

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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppColors.success.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: isSuccess ? AppColors.success : Colors.red,
                    size: 48,
                  ),
                )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                .fadeIn(),

            const SizedBox(height: 24),

            Text(
              isSuccess ? 'Top Up Berhasil Dibuat!' : 'Top Up Gagal',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            if (isSuccess && result != null) ...[
              // Detail card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _DialogRow(
                      label: 'Jumlah Top Up',
                      value: result!.amountFormatted,
                    ),
                    const Divider(color: AppColors.accentLight, height: 16),
                    _DialogRow(
                      label: 'Biaya Admin',
                      value: result!.serviceFeeFormatted,
                    ),
                    const Divider(color: AppColors.accentLight, height: 16),
                    _DialogRow(
                      label: 'Total Transfer',
                      value: result!.totalAmountFormatted,
                      bold: true,
                      valueColor: AppColors.success,
                    ),
                    const Divider(color: AppColors.accentLight, height: 16),
                    _DialogRow(
                      label: 'Status',
                      value: result!.status.toUpperCase(),
                      valueColor: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Reference code card (jika tersedia)
              if (result!.referenceCode != null) ...
              [
                Builder(
                  builder: (ctx) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.tag_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kode Referensi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                result!.referenceCode!,
                                style: const TextStyle(
                                  fontSize: 15,
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
                              ClipboardData(text: result!.referenceCode!),
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
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Salin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
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
                ),
                const SizedBox(height: 8),
              ],
              const Text(
                'Top up Anda sedang diproses. Admin akan memverifikasi pembayaran Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
            ] else ...[
              Text(
                errorMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 24),

            GlassButton(
              text: isSuccess ? 'Selesai' : 'Tutup',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({
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
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
