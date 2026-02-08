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
import '../providers/deposit_provider.dart';
import '../providers/transaction_provider.dart';

/// Withdrawal page with CRUD operations
class WithdrawalPage extends ConsumerStatefulWidget {
  const WithdrawalPage({super.key});

  @override
  ConsumerState<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends ConsumerState<WithdrawalPage> {
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

  Future<void> _handleWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = int.parse(
        _amountController.text.replaceAll(RegExp(r'\D'), ''),
      ).toDouble();

      // Check if balance is sufficient
      final currentBalance = ref.read(depositProvider).balance;
      if (amount > currentBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saldo tidak mencukupi'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final success = await ref
          .read(depositProvider.notifier)
          .createWithdrawal(
            amount: amount,
            description: _noteController.text.isEmpty
                ? 'Penarikan'
                : _noteController.text,
          );

      if (!mounted) return;

      if (success) {
        // Refresh transaction provider to sync data across pages
        await ref.read(transactionProvider.notifier).refresh();

        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _SuccessDialog(amount: amount.toInt()),
        );

        if (!mounted) return;
        context.go(Routes.savings);
      } else {
        final error = ref.read(depositProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal melakukan penarikan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositState = ref.watch(depositProvider);

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
                                Icons.account_balance_wallet,
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
                                    'Saldo Tersedia',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    Formatters.formatCurrency(
                                      depositState.balance,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.account_balance,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 32),

                      // Amount input section
                      const Text(
                        'Jumlah Penarikan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ).animate(delay: 100.ms).fadeIn(),

                      const SizedBox(height: 16),

                      // Amount field
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _ThousandSeparatorFormatter(),
                          ],
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'Rp ',
                            prefixStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            border: InputBorder.none,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan jumlah penarikan';
                            }
                            final amount = int.tryParse(
                              value.replaceAll(RegExp(r'\D'), ''),
                            );
                            if (amount == null || amount < 10000) {
                              return 'Minimal penarikan Rp 10.000';
                            }
                            if (amount > depositState.balance) {
                              return 'Saldo tidak mencukupi';
                            }
                            return null;
                          },
                          onChanged: (_) {
                            setState(() => _selectedPreset = null);
                          },
                        ),
                      ).animate(delay: 150.ms).fadeIn(),

                      const SizedBox(height: 20),

                      // Preset amounts
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _presetAmounts.map((amount) {
                          final isSelected = _selectedPreset == amount;
                          final isDisabled = amount > depositState.balance;
                          return GestureDetector(
                            onTap: isDisabled
                                ? null
                                : () => _selectPreset(amount),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppColors.primaryGradient
                                    : null,
                                color: isDisabled
                                    ? Colors.white.withOpacity(0.05)
                                    : (isSelected
                                          ? null
                                          : Colors.white.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDisabled
                                      ? Colors.white.withOpacity(0.1)
                                      : (isSelected
                                            ? Colors.transparent
                                            : Colors.white.withOpacity(0.2)),
                                ),
                              ),
                              child: Text(
                                Formatters.formatCurrency(amount),
                                style: TextStyle(
                                  color: isDisabled
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ).animate(delay: 200.ms).fadeIn(),

                      const SizedBox(height: 32),

                      // Note input
                      const Text(
                        'Keterangan (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ).animate(delay: 250.ms).fadeIn(),

                      const SizedBox(height: 12),

                      GlassContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: TextFormField(
                          controller: _noteController,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText:
                                'Contoh: Penarikan untuk kebutuhan darurat',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ).animate(delay: 300.ms).fadeIn(),

                      const SizedBox(height: 40),

                      // Withdrawal button
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          text: _isLoading ? 'Memproses...' : 'Tarik Dana',
                          icon: _isLoading ? null : Icons.arrow_upward,
                          onPressed: _isLoading ? null : _handleWithdrawal,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
                          ),
                        ),
                      ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),

                      const SizedBox(height: 80),
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

/// Success dialog
class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 40,
                    ),
                  )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                  .fadeIn(),

              const SizedBox(height: 16),

              const Text(
                'Penarikan Berhasil!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                Formatters.formatCurrency(amount),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B6B),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Telah ditarik dari Tabungan Utama',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'Selesai',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
