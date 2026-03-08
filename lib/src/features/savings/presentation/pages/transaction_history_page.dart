import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/services/hive_transaction_storage.dart' as hive_tx;
import '../providers/transaction_provider.dart';

/// Full transaction history page
class TransactionHistoryPage extends ConsumerStatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  ConsumerState<TransactionHistoryPage> createState() =>
      _TransactionHistoryPageState();
}

class _TransactionHistoryPageState
    extends ConsumerState<TransactionHistoryPage> {
  hive_tx.TransactionType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionProvider);

    final allTx = txState.transactions;
    final filtered = _selectedFilter == null
        ? allTx
        : allTx.where((t) => t.type == _selectedFilter).toList();

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
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Total count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${filtered.length} transaksi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: _selectedFilter == null,
                    onTap: () => setState(() => _selectedFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Setor',
                    isSelected:
                        _selectedFilter == hive_tx.TransactionType.deposit,
                    onTap: () => setState(
                      () => _selectedFilter = hive_tx.TransactionType.deposit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Tarik',
                    isSelected:
                        _selectedFilter == hive_tx.TransactionType.withdrawal,
                    onTap: () => setState(
                      () =>
                          _selectedFilter = hive_tx.TransactionType.withdrawal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Transfer',
                    isSelected:
                        _selectedFilter == hive_tx.TransactionType.transfer,
                    onTap: () => setState(
                      () => _selectedFilter = hive_tx.TransactionType.transfer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Lainnya',
                    isSelected:
                        _selectedFilter == hive_tx.TransactionType.interest,
                    onTap: () => setState(
                      () => _selectedFilter = hive_tx.TransactionType.interest,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _HistoryItem(transaction: filtered[index])
                            .animate(delay: (index * 40).ms)
                            .fadeIn(duration: 300.ms)
                            .slideX(begin: 0.04, end: 0);
                      },
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 15,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.transaction});

  final hive_tx.TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      opacity: 0.1,
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  (transaction.isCredit ? AppColors.success : AppColors.expense)
                      .withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(),
              color: transaction.isCredit
                  ? AppColors.success
                  : AppColors.expense,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  Formatters.formatDateTime(transaction.date),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isCredit ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: transaction.isCredit
                      ? AppColors.success
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _typeLabel(),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.type) {
      case hive_tx.TransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case hive_tx.TransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case hive_tx.TransactionType.transfer:
        return Icons.swap_horiz_rounded;
      case hive_tx.TransactionType.interest:
        return Icons.trending_up_rounded;
      case hive_tx.TransactionType.cashback:
        return Icons.card_giftcard_rounded;
      case hive_tx.TransactionType.purchase:
        return Icons.shopping_bag_outlined;
    }
  }

  String _typeLabel() {
    switch (transaction.type) {
      case hive_tx.TransactionType.deposit:
        return 'Setor';
      case hive_tx.TransactionType.withdrawal:
        return 'Tarik';
      case hive_tx.TransactionType.transfer:
        return 'Transfer';
      case hive_tx.TransactionType.interest:
        return 'Bunga';
      case hive_tx.TransactionType.cashback:
        return 'Cashback';
      case hive_tx.TransactionType.purchase:
        return 'Belanja';
    }
  }
}
