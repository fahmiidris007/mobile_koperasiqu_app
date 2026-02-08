import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_koperasiqu_app/src/core/router/app_router.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/savings_account.dart';
import '../../data/datasources/mock_savings_datasource.dart';

/// Savings provider
final savingsProvider = FutureProvider<SavingsAccount>((ref) async {
  final datasource = MockSavingsDatasource();
  return datasource.getPrimarySavings();
});

/// Monthly summary provider
final monthlySummaryProvider = FutureProvider<List<MonthlySummary>>((
  ref,
) async {
  final datasource = MockSavingsDatasource();
  final savings = await ref.watch(savingsProvider.future);
  return datasource.getMonthlySummary(savings.id);
});

/// Savings detail page with chart
class SavingsDetailPage extends ConsumerWidget {
  const SavingsDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(savingsProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 100), // Space for nav bar
      child: savingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (savings) => _SavingsContent(
          savings: savings,
          monthlySummary: summaryAsync.valueOrNull ?? [],
        ),
      ),
    );
  }
}

class _SavingsContent extends StatelessWidget {
  const _SavingsContent({required this.savings, required this.monthlySummary});

  final SavingsAccount savings;
  final List<MonthlySummary> monthlySummary;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                // GestureDetector(
                //   onTap: () => context.go('/dashboard'),
                //   child: Container(
                //     width: 44,
                //     height: 44,
                //     decoration: BoxDecoration(
                //       color: Colors.white.withOpacity(0.15),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: const Icon(Icons.arrow_back, color: Colors.white),
                //   ),
                // ),
                // const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Tabungan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        // Balance card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _buildBalanceCard(
              context,
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          ),
        ),

        // Chart
        if (monthlySummary.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildChart(
                context,
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
            ),
          ),

        // Action buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    text: 'Setor',
                    icon: Icons.add,
                    onPressed: () => context.push(Routes.deposit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassOutlineButton(
                    text: 'Tarik',
                    icon: Icons.arrow_upward,
                    onPressed: () {},
                  ),
                ),
              ],
            ).animate(delay: 300.ms).fadeIn(duration: 500.ms),
          ),
        ),

        // Transaction history header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Transaction list
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final tx = savings.transactions[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: _TransactionItem(
                transaction: tx,
              ).animate(delay: (400 + index * 80).ms).fadeIn(duration: 400.ms),
            );
          }, childCount: savings.transactions.length),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      blur: 30,
      opacity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.savings, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savings.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.maskAccountNumber(savings.accountNumber),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${savings.interestRate}% p.a.',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Saldo Tersedia',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(savings.balance),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perkembangan Saldo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final months = [
                          'Jul',
                          'Ags',
                          'Sep',
                          'Okt',
                          'Nov',
                          'Des',
                        ];
                        if (value.toInt() < 0 ||
                            value.toInt() >= months.length) {
                          return const Text('');
                        }
                        return Text(
                          months[value.toInt()],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlySummary.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        e.value.endBalance / 1000000,
                      );
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    gradient: AppColors.primaryGradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeColor: AppColors.primary,
                          strokeWidth: 2,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});

  final SavingsTransaction transaction;

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  (transaction.isCredit ? AppColors.success : AppColors.expense)
                      .withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 2),
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
          Text(
            '${transaction.isCredit ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: transaction.isCredit ? AppColors.success : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (transaction.type) {
      case SavingsTransactionType.deposit:
        return Icons.arrow_downward_rounded;
      case SavingsTransactionType.withdrawal:
        return Icons.arrow_upward_rounded;
      case SavingsTransactionType.transfer:
        return Icons.swap_horiz_rounded;
      case SavingsTransactionType.interest:
        return Icons.trending_up_rounded;
      case SavingsTransactionType.cashback:
        return Icons.card_giftcard_rounded;
      case SavingsTransactionType.fee:
        return Icons.remove_circle_outline;
    }
  }
}
