import 'package:equatable/equatable.dart';

/// Product entity for shopping catalog
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.originalPrice,
    this.stock = 100,
    this.rating = 4.5,
    this.soldCount = 0,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // For discount display
  final String imageUrl;
  final ProductCategory category;
  final int stock;
  final double rating;
  final int soldCount;
  final bool isAvailable;

  /// Calculate discount percentage
  double? get discountPercent {
    if (originalPrice == null || originalPrice! <= price) return null;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    originalPrice,
    imageUrl,
    category,
    stock,
    rating,
    soldCount,
    isAvailable,
  ];
}

enum ProductCategory {
  sembako,
  household,
  electronics,
  fashion,
  health,
  other;

  String get displayName {
    switch (this) {
      case ProductCategory.sembako:
        return 'Sembako';
      case ProductCategory.household:
        return 'Rumah Tangga';
      case ProductCategory.electronics:
        return 'Elektronik';
      case ProductCategory.fashion:
        return 'Fashion';
      case ProductCategory.health:
        return 'Kesehatan';
      case ProductCategory.other:
        return 'Lainnya';
    }
  }

  String get icon {
    switch (this) {
      case ProductCategory.sembako:
        return 'grocery';
      case ProductCategory.household:
        return 'home';
      case ProductCategory.electronics:
        return 'devices';
      case ProductCategory.fashion:
        return 'checkroom';
      case ProductCategory.health:
        return 'medical';
      case ProductCategory.other:
        return 'category';
    }
  }
}

/// Cart item
class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  @override
  List<Object?> get props => [product, quantity];
}

/// Shopping cart
class Cart extends Equatable {
  const Cart({this.items = const []});

  final List<CartItem> items;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => items.isEmpty;

  Cart addItem(Product product) {
    final existingIndex = items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final updated = List<CartItem>.from(items);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + 1,
      );
      return Cart(items: updated);
    }
    return Cart(
      items: [
        ...items,
        CartItem(product: product, quantity: 1),
      ],
    );
  }

  Cart updateQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeItem(productId);
    final updated = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    return Cart(items: updated);
  }

  Cart removeItem(String productId) {
    return Cart(items: items.where((i) => i.product.id != productId).toList());
  }

  Cart clear() => const Cart();

  @override
  List<Object?> get props => [items];
}
