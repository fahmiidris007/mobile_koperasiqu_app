import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';

/// Cart state provider
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(const Cart());

  /// Add product to cart
  void addToCart(Product product) {
    state = state.addItem(product);
  }

  /// Update item quantity
  void updateQuantity(String productId, int quantity) {
    state = state.updateQuantity(productId, quantity);
  }

  /// Remove item from cart
  void removeItem(String productId) {
    state = state.removeItem(productId);
  }

  /// Clear cart
  void clearCart() {
    state = state.clear();
  }
}
