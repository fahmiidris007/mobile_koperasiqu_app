import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../savings/domain/entities/branch_info.dart';
import '../../../savings/domain/entities/wallet_info.dart';
import '../../../savings/domain/entities/wallet_transaction.dart';
import '../../../savings/presentation/providers/branch_provider.dart';
import '../../../savings/presentation/providers/wallet_provider.dart';
import '../providers/banner_provider.dart';
import '../../data/datasources/banner_datasource.dart';

/// Main dashboard page
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final walletTxAsync = ref.watch(walletTransactionsProvider);
    final authState = ref.watch(authProvider);
    final branchAsync = ref.watch(branchProvider);

    // Resolve user name from auth state
    String userName = '';
    if (authState is AuthAuthenticated) {
      userName = authState.user.name;
    } else if (authState is AuthPending) {
      userName = authState.user.name;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: walletAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (wallet) => _DashboardContent(
          wallet: wallet,
          transactions: walletTxAsync.valueOrNull ?? [],
          userName: userName,
          branchAsync: branchAsync,
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.wallet,
    required this.transactions,
    required this.userName,
    required this.branchAsync,
  });

  final WalletInfo wallet;
  final List<WalletTransaction> transactions;
  final String userName;
  final AsyncValue<BranchInfo> branchAsync;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header with greeting and notification
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildHeader(context),
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

        // Rekening koperasi card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildRekeningCard(context)
                .animate(delay: 200.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.05, end: 0),
          ),
        ),

        // Promo banner carousel
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
            child: const _PromoCarousel()
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms),
          ),
        ),

        // Recent transactions header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaksi Terkini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(Routes.transactionHistory),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Transaction list from wallet API
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final tx = transactions.take(5).toList()[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: GestureDetector(
                onTap: () => context.push(Routes.transactionDetail, extra: tx),
                child: _WalletTransactionItem(transaction: tx)
                    .animate(delay: (400 + index * 100).ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.05, end: 0),
              ),
            );
          }, childCount: transactions.take(5).length),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final initial = userName.isNotEmpty
        ? userName
              .trim()
              .split(' ')
              .map((w) => w[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'K';
    return Row(
      children: [
        // Avatar - tap to go to profile
        GestureDetector(
          onTap: () => context.push(Routes.profile),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang,',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                userName.isNotEmpty ? userName : 'Anggota',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Notification bell
        GlassIconButton(
          icon: Icons.notifications_outlined,
          onPressed: () => context.push(Routes.notifications),
          size: 44,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tabungan',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            wallet.balanceFormatted,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Saldo Wallet',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.add,
                  label: 'Setor',
                  onTap: () => context.push(Routes.deposit),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.arrow_upward,
                  label: 'Tarik',
                  onTap: () => context.push(Routes.withdrawal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRekeningCard(BuildContext context) {
    final accountNumber = branchAsync.whenOrNull(
          data: (b) => b.bankAccountNumber,
        ) ??
        '—';
    final bankLabel = branchAsync.whenOrNull(
          data: (b) => '${b.bankName} · ${b.bankAccountName}',
        ) ??
        'No. Rekening KoperasiQu';

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      opacity: 0.12,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                branchAsync.isLoading
                    ? const SizedBox(
                        height: 14,
                        width: 140,
                        child: LinearProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
                        accountNumber,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.8,
                        ),
                      ),
              ],
            ),
          ),
          GestureDetector(
            onTap: accountNumber == '—'
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: accountNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nomor rekening disalin!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Salin',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction item for WalletTransaction (real API)
class _WalletTransactionItem extends StatelessWidget {
  const _WalletTransactionItem({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      opacity: 0.1,
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.expense)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(),
              color: isCredit ? AppColors.success : AppColors.expense,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.typeLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: transaction.isPending
                        ? Colors.orange
                        : AppColors.textMuted,
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
                '${isCredit ? '+' : ''}${transaction.amountFormatted}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatRelativeDate(transaction.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
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
      case 'topup':
        return Icons.arrow_downward_rounded;
      case 'payment':
        return Icons.shopping_bag_outlined;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return Formatters.formatDate(date);
  }
}

// ── Promo Carousel ────────────────────────────────────────────────────────────

/// Model data promo lokal (fallback ketika API belum ada data)
class _PromoItem {
  const _PromoItem({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String label;
  final IconData icon;
  final Color accentColor;
  final String badge;
}

/// List data promo lokal — dipakai jika API /banners masih kosong
const List<_PromoItem> _localPromos = [
  _PromoItem(
    title: 'Cashback Top Up! 💸',
    subtitle: 'Cashback 5% setiap top up min. Rp 500.000',
    label: 'Klaim',
    icon: Icons.local_offer_rounded,
    accentColor: Color(0xFF6C63FF),
    badge: 'TERBARU',
  ),
  _PromoItem(
    title: 'Bunga Tabungan Spesial 🏦',
    subtitle: 'Bunga 8% p.a. untuk saldo min. Rp 1.000.000',
    label: 'Info',
    icon: Icons.savings_rounded,
    accentColor: Color(0xFF0BA360),
    badge: 'HOT',
  ),
  _PromoItem(
    title: 'Belanja Dapat Poin! 🛒',
    subtitle: 'Kumpulkan poin reward setiap transaksi belanja',
    label: 'Mulai',
    icon: Icons.card_giftcard_rounded,
    accentColor: Color(0xFFFF6B6B),
    badge: 'LIMITED',
  ),
  _PromoItem(
    title: 'Referral Bonus 🎁',
    subtitle: 'Undang teman, dapatkan bonus Rp 50.000',
    label: 'Undang',
    icon: Icons.people_alt_rounded,
    accentColor: Color(0xFF3F5EFB),
    badge: 'PROMO',
  ),
];

/// Carousel promo — membaca dari API /banners, fallback ke lokal jika kosong
class _PromoCarousel extends ConsumerStatefulWidget {
  const _PromoCarousel();

  @override
  ConsumerState<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends ConsumerState<_PromoCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  static const _autoScrollDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _scheduleAutoScroll();
  }

  int _itemCount(List<BannerModel> apiBanners) =>
      apiBanners.isNotEmpty ? apiBanners.length : _localPromos.length;

  void _scheduleAutoScroll() {
    Future.delayed(_autoScrollDuration, () {
      if (!mounted) return;
      final count = _itemCount(
        ref.read(bannerProvider).valueOrNull ?? [],
      );
      if (count == 0) return;
      final next = (_currentPage + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _scheduleAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(bannerProvider);
    final apiBanners = bannersAsync.valueOrNull ?? [];
    final useApi = apiBanners.isNotEmpty;
    final count = _itemCount(apiBanners);

    if (count == 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 116,
          child: PageView.builder(
            controller: _pageController,
            itemCount: count,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return AnimatedScale(
                scale: _currentPage == index ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: useApi
                      ? _ApiBannerCard(banner: apiBanners[index])
                      : _PromoBannerCard(promo: _localPromos[index]),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.accentLight,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Card untuk banner dari API (dengan imageUrl)
class _ApiBannerCard extends StatelessWidget {
  const _ApiBannerCard({required this.banner});

  final BannerModel banner;

  Color get _accentColor {
    switch (banner.type) {
      case 'promo':
        return const Color(0xFF6C63FF);
      case 'news':
        return const Color(0xFF0BA360);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 20,
      opacity: 0.15,
      child: Row(
        children: [
          // Image atau icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: banner.imageUrl != null
                ? Image.network(
                    banner.imageUrl!,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        banner.isPromo
                            ? Icons.local_offer_rounded
                            : Icons.newspaper_rounded,
                        color: _accentColor,
                        size: 22,
                      ),
                    ),
                  )
                : Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      banner.isPromo
                          ? Icons.local_offer_rounded
                          : Icons.newspaper_rounded,
                      color: _accentColor,
                      size: 22,
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    banner.isPromo ? 'PROMO' : 'NEWS',
                    style: TextStyle(
                      color: _accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (banner.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    banner.description!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card untuk item promo lokal (fallback)
class _PromoBannerCard extends StatelessWidget {
  const _PromoBannerCard({required this.promo});

  final _PromoItem promo;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 20,
      opacity: 0.15,
      child: Row(
        children: [
          // Icon circle dengan accent color
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: promo.accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: promo.accentColor.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Icon(promo.icon, color: promo.accentColor, size: 22),
          ),

          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: promo.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    promo.badge,
                    style: TextStyle(
                      color: promo.accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  promo.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  promo.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // CTA button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: promo.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: promo.accentColor.withOpacity(0.5)),
            ),
            child: Text(
              promo.label,
              style: TextStyle(
                color: promo.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
