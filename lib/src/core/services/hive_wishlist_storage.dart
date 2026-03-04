import 'package:hive_flutter/hive_flutter.dart';

/// Wishlist item model for Hive storage
class WishlistItem {
  WishlistItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.addedAt,
    this.originalPrice,
  });

  final String productId;
  final String productName;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final DateTime addedAt;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'category': category,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WishlistItem.fromMap(Map<dynamic, dynamic> map) {
    return WishlistItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      price: (map['price'] as num).toDouble(),
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : null,
      imageUrl: map['imageUrl'] as String,
      category: map['category'] as String,
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }
}

/// Hive-based wishlist storage service
class HiveWishlistStorage {
  static const String _wishlistBox = 'wishlist';

  static HiveWishlistStorage? _instance;
  late Box<Map> _box;
  bool _isInitialized = false;

  HiveWishlistStorage._();

  static Future<HiveWishlistStorage> getInstance() async {
    if (_instance == null) {
      _instance = HiveWishlistStorage._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_wishlistBox);
    _isInitialized = true;
  }

  /// Get all wishlist items sorted by addedAt (newest first)
  List<WishlistItem> getAll() {
    return _box.values.map((e) => WishlistItem.fromMap(e)).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  /// Check if a product is in wishlist
  bool contains(String productId) {
    return _box.containsKey(productId);
  }

  /// Add product to wishlist
  Future<void> add(WishlistItem item) async {
    await _box.put(item.productId, item.toMap());
  }

  /// Remove product from wishlist
  Future<void> remove(String productId) async {
    await _box.delete(productId);
  }

  /// Toggle wishlist (add if not exists, remove if exists)
  Future<bool> toggle(WishlistItem item) async {
    if (contains(item.productId)) {
      await remove(item.productId);
      return false; // removed
    } else {
      await add(item);
      return true; // added
    }
  }

  /// Clear all wishlist
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get count
  int get count => _box.length;
}
