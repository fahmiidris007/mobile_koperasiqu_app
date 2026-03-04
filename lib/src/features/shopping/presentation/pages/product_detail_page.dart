import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product.dart';
import '../../data/datasources/mock_shopping_datasource.dart';
import '../providers/wishlist_provider.dart';

/// Product by ID provider
final productByIdProvider = FutureProvider.family<Product?, String>((
  ref,
  id,
) async {
  final datasource = MockShoppingDatasource();
  return datasource.getProductById(id);
});

/// Product detail page
class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return SimpleGradientBackground(
      child: productAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (product) {
          if (product == null) {
            return const Center(
              child: Text(
                'Produk tidak ditemukan',
                style: TextStyle(color: Colors.white),
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

  final Product product;

  @override
  ConsumerState<_ProductDetailContent> createState() =>
      _ProductDetailContentState();
}

class _ProductDetailContentState extends ConsumerState<_ProductDetailContent> {
  static const String _waNumber = '6288294392767';

  Future<void> _openWhatsApp(BuildContext context, dynamic product) async {
    final productName = product.name as String;
    final price = Formatters.formatCurrency(product.price as double);
    final category = (product.category.displayName) as String;

    final message =
        'Halo Admin KoperasiQu! 👋\n\n'
        'Saya tertarik untuk membeli produk berikut:\n'
        '📦 *$productName*\n'
        '🏷️ Kategori: $category\n'
        '💰 Harga: $price\n\n'
        'Apakah produk ini masih tersedia? Mohon informasi lebih lanjut. Terima kasih! 🙏';

    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$_waNumber?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp tidak ditemukan di perangkat ini'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isWishlisted = ref.watch(
      wishlistProvider.select((s) => s.contains(product.id)),
    );

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
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const Spacer(),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.share, color: Colors.white),
              ),
              const SizedBox(width: 8),
              // Wishlist toggle button
              GestureDetector(
                onTap: () async {
                  final added = await ref
                      .read(wishlistProvider.notifier)
                      .toggle(product);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          added
                              ? 'Ditambahkan ke wishlist'
                              : 'Dihapus dari wishlist',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: added ? Colors.green : Colors.grey,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isWishlisted
                        ? Colors.red.withOpacity(0.2)
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: double.infinity,
                  height: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      if (product.discountPercent != null)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '-${product.discountPercent!.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 24),

                // Product info
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
                            product.category.displayName,
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
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Rating and sold count
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${product.soldCount} terjual',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Price
                        Row(
                          children: [
                            Text(
                              Formatters.formatCurrency(product.price),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.teal,
                              ),
                            ),
                            if (product.originalPrice != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                Formatters.formatCurrency(
                                  product.originalPrice!,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.5),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const Divider(color: Colors.white24, height: 32),

                        // Description
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.7),
                          ),
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

        // Bottom bar
        // Container(
        //   padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        //   decoration: BoxDecoration(
        //     color: Colors.black.withOpacity(0.3),
        //     border: Border(
        //       top: BorderSide(color: Colors.white.withOpacity(0.1)),
        //     ),
        //   ),
        //   child: Row(
        //     children: [
        //       // Quantity selector
        //       Container(
        //         decoration: BoxDecoration(
        //           color: Colors.white.withOpacity(0.1),
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //         child: Row(
        //           children: [
        //             IconButton(
        //               icon: const Icon(
        //                 Icons.remove,
        //                 color: Colors.white,
        //                 size: 18,
        //               ),
        //               onPressed: _quantity > 1
        //                   ? () => setState(() => _quantity--)
        //                   : null,
        //             ),
        //             SizedBox(
        //               width: 32,
        //               child: Center(
        //                 child: Text(
        //                   '$_quantity',
        //                   style: const TextStyle(
        //                     color: Colors.white,
        //                     fontWeight: FontWeight.bold,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             IconButton(
        //               icon: const Icon(
        //                 Icons.add,
        //                 color: Colors.white,
        //                 size: 18,
        //               ),
        //               onPressed: () => setState(() => _quantity++),
        //             ),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(width: 12),

        //       // Add to cart button
        //       Expanded(
        //         child: GlassButton(
        //           text: 'Tambah ke Keranjang',
        //           icon: Icons.shopping_cart,
        //           onPressed: _addToCart,
        //           textStyle: const TextStyle(
        //             fontSize: 12,
        //             fontWeight: FontWeight.w600,
        //             color: Colors.white,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // Bottom bar - Beli di WhatsApp
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: GestureDetector(
            onTap: () => _openWhatsApp(context, product),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/6/6b/WhatsApp.svg',
                    width: 24,
                    height: 24,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.chat_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
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
