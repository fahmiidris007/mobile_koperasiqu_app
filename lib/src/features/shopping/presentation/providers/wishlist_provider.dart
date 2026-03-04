import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_koperasiqu_app/src/core/services/hive_wishlist_storage.dart';
import '../../domain/entities/product.dart';

/// Wishlist state
class WishlistState {
  const WishlistState({this.items = const [], this.isLoading = false});

  final List<WishlistItem> items;
  final bool isLoading;

  Set<String> get productIds => items.map((e) => e.productId).toSet();

  bool contains(String productId) => productIds.contains(productId);

  WishlistState copyWith({List<WishlistItem>? items, bool? isLoading}) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Wishlist provider
final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>(
  (ref) {
    return WishlistNotifier();
  },
);

class WishlistNotifier extends StateNotifier<WishlistState> {
  WishlistNotifier() : super(const WishlistState()) {
    _load();
  }

  HiveWishlistStorage? _storage;

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    _storage = await HiveWishlistStorage.getInstance();
    state = state.copyWith(items: _storage!.getAll(), isLoading: false);
  }

  /// Toggle wishlist for a product
  Future<bool> toggle(Product product) async {
    _storage ??= await HiveWishlistStorage.getInstance();

    final item = WishlistItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      originalPrice: product.originalPrice,
      imageUrl: product.imageUrl,
      category: product.category.displayName,
      addedAt: DateTime.now(),
    );

    final wasAdded = await _storage!.toggle(item);
    state = state.copyWith(items: _storage!.getAll());
    return wasAdded;
  }

  /// Check if product is in wishlist
  bool isWishlisted(String productId) => state.contains(productId);

  /// Remove from wishlist
  Future<void> remove(String productId) async {
    _storage ??= await HiveWishlistStorage.getInstance();
    await _storage!.remove(productId);
    state = state.copyWith(items: _storage!.getAll());
  }

  /// Clear all wishlist
  Future<void> clearAll() async {
    _storage ??= await HiveWishlistStorage.getInstance();
    await _storage!.clearAll();
    state = state.copyWith(items: []);
  }
}
