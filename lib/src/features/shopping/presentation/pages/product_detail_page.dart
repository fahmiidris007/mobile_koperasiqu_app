import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';
import '../../data/datasources/shopping_datasource.dart';
import '../../domain/entities/product.dart';
import '../providers/shopping_provider.dart';
import '../providers/wishlist_provider.dart';
import '../../../savings/presentation/providers/branch_provider.dart';

/// Product detail by ID from pre-loaded products list
final productDetailProvider = FutureProvider.autoDispose
    .family<ApiProduct?, String>((ref, id) async {
      final products = await ref.watch(productsApiProvider.future);
      try {
        return products.firstWhere((p) => p.idStr == id);
      } catch (_) {
        return null;
      }
    });

/// Product detail page
class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return SimpleGradientBackground(
      child: productAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppColors.textPrimary)),
        ),
        data: (product) {
          if (product == null) {
            return const Center(
              child: Text(
                'Produk tidak ditemukan',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return _ProductDetailContent(product: product);
        },
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerStatefulWidget {
  const _ProductDetailContent({required this.product});

  final ApiProduct product;

  @override
  ConsumerState<_ProductDetailContent> createState() =>
      _ProductDetailContentState();
}

class _ProductDetailContentState extends ConsumerState<_ProductDetailContent> {

  Future<void> _openWhatsApp(BuildContext context, String waNumber) async {
    final product = widget.product;

    // Record product click/interest — fire-and-forget
    unawaited(ShoppingDatasource().recordProductClick(product.idStr));

    final message =
        'Halo Admin KoperasiQu! 👋\n\n'
        'Saya tertarik untuk membeli produk berikut:\n'
        '📦 *${product.name}*\n'
        '🏷️ Kategori: ${product.category.name}\n'
        '💰 Harga: ${product.priceFormatted}\n\n'
        'Apakah produk ini masih tersedia? Mohon informasi lebih lanjut. Terima kasih! 🙏';

    final encodedMessage = Uri.encodeComponent(message);

    // Prioritaskan deep link WhatsApp app, fallback ke browser
    final appUrl = Uri.parse(
      'whatsapp://send?phone=$waNumber&text=$encodedMessage',
    );
    final webUrl = Uri.parse('https://wa.me/$waNumber?text=$encodedMessage');

    try {
      // Coba buka langsung ke app WhatsApp
      final launched = await launchUrl(
        appUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Jika gagal, fallback ke browser (wa.me)
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback ke wa.me di browser
      try {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstall.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'coffee':
        return Icons.coffee;
      case 'fastfood':
        return Icons.fastfood;
      case 'local_drink':
        return Icons.local_drink;
      case 'shopping_basket':
        return Icons.shopping_basket;
      case 'card_giftcard':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isWishlisted = ref.watch(
      wishlistProvider.select((s) => s.containsApiId(product.id)),
    );
    final branchAsync = ref.watch(branchProvider);
    final waNumber = branchAsync.whenOrNull(data: (b) => b.whatsappNumber) ?? '';

    return Column(
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
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              // Wishlist toggle
              GestureDetector(
                onTap: () {
                  ref.read(wishlistProvider.notifier).toggleApiProduct(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isWishlisted
                            ? 'Dihapus dari wishlist'
                            : 'Ditambahkan ke wishlist',
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: isWishlisted
                          ? Colors.grey
                          : AppColors.primary,
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isWishlisted
                        ? Colors.red.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image / placeholder
                Container(
                  width: double.infinity,
                  height: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: product.thumbnailUrl != null
                            ? Image.network(
                                product.thumbnailUrl!,
                                width: double.infinity,
                                height: 280,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Icon(
                                    _resolveIcon(product.category.iconName),
                                    size: 80,
                                    color: AppColors.accentLight,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  _resolveIcon(product.category.iconName),
                                  size: 80,
                                  color: AppColors.accentLight,
                                ),
                              ),
                      ),
                      if (product.isFeatured)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Unggulan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 24),

                // Product info card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category.name,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Name
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Rating + service time
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rate.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '~${product.serviceTime} menit',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Price
                        Text(
                          product.priceFormatted,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        const Divider(color: AppColors.accentLight, height: 32),

                        // Info rows
                        _InfoRow(
                          icon: Icons.category_outlined,
                          label: 'Kategori',
                          value: product.category.name,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.schedule,
                          label: 'Waktu Layanan',
                          value: '${product.serviceTime} menit',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.verified_outlined,
                          label: 'Status',
                          value: product.isFeatured
                              ? 'Produk Unggulan'
                              : 'Reguler',
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),

        // Bottom bar: Beli via WhatsApp
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(
              top: BorderSide(color: AppColors.accentLight),
            ),
          ),
          child: GestureDetector(
            onTap: waNumber.isEmpty
                ? null
                : () => _openWhatsApp(context, waNumber),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Beli di WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
