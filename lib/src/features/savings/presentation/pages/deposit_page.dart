import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../providers/wallet_provider.dart';
import '../../domain/entities/wallet_transaction.dart';

/// Deposit page with CRUD operations
class DepositPage extends ConsumerStatefulWidget {
  const DepositPage({super.key});

  @override
  ConsumerState<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends ConsumerState<DepositPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  int? _selectedPreset;

  static const List<int> _presetAmounts = [100000, 250000, 500000, 1000000];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectPreset(int amount) {
    setState(() {
      _selectedPreset = amount;
      _amountController.text = amount.toString();
    });
  }

  Future<void> _handleDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = int.parse(
        _amountController.text.replaceAll(RegExp(r'\D'), ''),
      ).toDouble();

      final result = await ref
          .read(topupNotifierProvider.notifier)
          .topup(amount: amount);

      if (!mounted) return;

      if (result != null) {
        // Show success dialog with topup details
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _TopupSuccessDialog(result: result),
        );

        if (!mounted) return;
        context.go(Routes.savings);
      } else {
        final error = ref.read(topupNotifierProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal melakukan top up'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log('error top up $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep provider alive while page is mounted (fixes autoDispose bad-state during async topup)
    ref.watch(topupNotifierProvider);

    return SimpleGradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header
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
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Setoran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Current balance info
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        opacity: 0.1,
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.savings,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KoperasiQu Wallet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final wallet = ref
                                          .watch(walletProvider)
                                          .valueOrNull;
                                      return Text(
                                        wallet?.balanceFormatted ?? '-',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 32),

                      // Amount input
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jumlah Setoran',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rp',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _ThousandSeparatorFormatter(),
                                    ],
                                    validator: (v) =>
                                        Validators.minAmount(v, 10000),
                                    onChanged: (_) {
                                      setState(() => _selectedPreset = null);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Preset amounts
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _presetAmounts.map((amount) {
                                final isSelected = _selectedPreset == amount;
                                return GestureDetector(
                                  onTap: () => _selectPreset(amount),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      Formatters.formatCurrency(amount),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Note
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catatan (opsional)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _noteController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Contoh: Setoran bulanan',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 32),

                      // Submit button
                      GlassButton(
                        text: 'Konfirmasi Top Up',
                        isLoading: _isLoading,
                        onPressed: _handleDeposit,
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // History link
                      Center(
                        child: TextButton.icon(
                          onPressed: () =>
                              context.push(Routes.transactionHistory),
                          icon: const Icon(
                            Icons.history,
                            color: Colors.white70,
                            size: 18,
                          ),
                          label: Text(
                            'Lihat Riwayat Transaksi',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thousand separator formatter
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) return oldValue;

    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Top Up success dialog — shows real topup result from API
class _TopupSuccessDialog extends StatelessWidget {
  const _TopupSuccessDialog({required this.result});

  final TopupResult result;

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
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pending_actions,
                    color: AppColors.teal,
                    size: 48,
                  ),
                )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                .fadeIn(),

            const SizedBox(height: 24),

            const Text(
              'Top Up Berhasil Dibuat!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Detail card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Jumlah Top Up',
                    value: result.amountFormatted,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _DetailRow(
                    label: 'Biaya Admin',
                    value: result.serviceFeeFormatted,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _DetailRow(
                    label: 'Total Transfer',
                    value: result.totalAmountFormatted,
                    bold: true,
                    valueColor: AppColors.success,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _DetailRow(
                    label: 'Kode Unik',
                    value: result.uniqueCode.toString(),
                    bold: true,
                    valueColor: Colors.orangeAccent,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _DetailRow(
                    label: 'Status',
                    value: result.status.toUpperCase(),
                    valueColor: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Lakukan transfer sesuai jumlah total di atas termasuk kode unik ke rekening tujuan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 24),

            GlassButton(
              text: 'Selesai',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
