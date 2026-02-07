import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';

/// PPOB entity
class PpobService {
  const PpobService({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
  });

  final String id;
  final String name;
  final IconData icon;
  final String category;
}

/// PPOB Menu Page
class PpobMenuPage extends StatelessWidget {
  const PpobMenuPage({super.key});

  static const List<PpobService> _services = [
    PpobService(
      id: 'pulsa',
      name: 'Pulsa',
      icon: Icons.phone_android,
      category: 'Telekomunikasi',
    ),
    PpobService(
      id: 'paket_data',
      name: 'Paket Data',
      icon: Icons.wifi,
      category: 'Telekomunikasi',
    ),
    PpobService(
      id: 'pln',
      name: 'Token PLN',
      icon: Icons.electric_bolt,
      category: 'Listrik',
    ),
    PpobService(
      id: 'pln_tagihan',
      name: 'Tagihan PLN',
      icon: Icons.receipt,
      category: 'Listrik',
    ),
    PpobService(
      id: 'pdam',
      name: 'PDAM',
      icon: Icons.water_drop,
      category: 'Air',
    ),
    PpobService(
      id: 'bpjs',
      name: 'BPJS',
      icon: Icons.health_and_safety,
      category: 'Asuransi',
    ),
    PpobService(
      id: 'internet',
      name: 'Internet & TV',
      icon: Icons.router,
      category: 'Telekomunikasi',
    ),
    PpobService(
      id: 'game',
      name: 'Voucher Game',
      icon: Icons.games,
      category: 'Hiburan',
    ),
    PpobService(
      id: 'streaming',
      name: 'Streaming',
      icon: Icons.play_circle,
      category: 'Hiburan',
    ),
    PpobService(
      id: 'emoney',
      name: 'E-Money',
      icon: Icons.account_balance_wallet,
      category: 'Pembayaran',
    ),
    PpobService(
      id: 'cicilan',
      name: 'Cicilan',
      icon: Icons.credit_card,
      category: 'Pembayaran',
    ),
    PpobService(
      id: 'more',
      name: 'Lainnya',
      icon: Icons.more_horiz,
      category: 'Lainnya',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pembayaran & Pembelian',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bayar tagihan dan beli kebutuhan digital',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),

          // Promo banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: 20,
                opacity: 0.1,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.teal.withOpacity(0.6),
                        AppColors.primary.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.local_offer,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Promo Token PLN! ⚡',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Cashback hingga Rp 20.000',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // Services grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final service = _services[index];
                return _ServiceItem(service: service)
                    .animate(delay: (100 + index * 50).ms)
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.9, 0.9));
              }, childCount: _services.length),
            ),
          ),

          // Recent transactions header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi Terakhir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(color: AppColors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recent transactions
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: _RecentTransaction(index: index)
                    .animate(delay: (400 + index * 80).ms)
                    .fadeIn(duration: 400.ms),
              );
            }, childCount: 3),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({required this.service});

  final PpobService service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${service.name} - Coming soon'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(service.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            service.name,
            style: const TextStyle(fontSize: 11, color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RecentTransaction extends StatelessWidget {
  const _RecentTransaction({required this.index});

  final int index;

  static const _transactions = [
    {
      'name': 'Pulsa Telkomsel',
      'number': '0812***789',
      'amount': 50000,
      'icon': Icons.phone_android,
    },
    {
      'name': 'Token PLN',
      'number': '12345***90',
      'amount': 100000,
      'icon': Icons.electric_bolt,
    },
    {
      'name': 'Paket Data XL',
      'number': '0878***456',
      'amount': 75000,
      'icon': Icons.wifi,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tx = _transactions[index];

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
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
            child: Icon(tx['icon'] as IconData, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  tx['number'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${(tx['amount'] as int).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Sukses',
                style: TextStyle(fontSize: 11, color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
