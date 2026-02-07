import '../../domain/entities/product.dart';

/// Mock data source for shopping
class MockShoppingDatasource {
  MockShoppingDatasource();

  /// Get all products
  Future<List<Product>> getProducts({ProductCategory? category}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (category != null) {
      return _mockProducts.where((p) => p.category == category).toList();
    }
    return _mockProducts;
  }

  /// Get product by ID
  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockProducts.firstWhere((p) => p.id == id);
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts.take(4).toList();
  }

  /// Get categories
  List<ProductCategory> getCategories() {
    return ProductCategory.values;
  }

  // Mock products
  static final List<Product> _mockProducts = [
    const Product(
      id: 'prod-001',
      name: 'Beras Premium 5kg',
      description:
          'Beras putih premium kualitas terbaik dari petani lokal. Pulen dan wangi, cocok untuk makanan sehari-hari.',
      price: 75000,
      originalPrice: 85000,
      imageUrl: 'https://placehold.co/400x400/3B82F6/FFFFFF?text=Beras',
      category: ProductCategory.sembako,
      rating: 4.8,
      soldCount: 1250,
    ),
    const Product(
      id: 'prod-002',
      name: 'Minyak Goreng 2L',
      description:
          'Minyak goreng kelapa sawit berkualitas, jernih dan tidak berbusa.',
      price: 32000,
      originalPrice: 38000,
      imageUrl: 'https://placehold.co/400x400/10B981/FFFFFF?text=Minyak',
      category: ProductCategory.sembako,
      rating: 4.6,
      soldCount: 890,
    ),
    const Product(
      id: 'prod-003',
      name: 'Gula Pasir 1kg',
      description:
          'Gula pasir putih bersih, manis sempurna untuk minuman dan masakan.',
      price: 14500,
      imageUrl: 'https://placehold.co/400x400/F59E0B/FFFFFF?text=Gula',
      category: ProductCategory.sembako,
      rating: 4.5,
      soldCount: 2100,
    ),
    const Product(
      id: 'prod-004',
      name: 'Sabun Cuci Piring 800ml',
      description:
          'Sabun cuci piring dengan formula anti lemak, bersih tanpa residu.',
      price: 18000,
      originalPrice: 22000,
      imageUrl: 'https://placehold.co/400x400/8B5CF6/FFFFFF?text=Sabun',
      category: ProductCategory.household,
      rating: 4.4,
      soldCount: 560,
    ),
    const Product(
      id: 'prod-005',
      name: 'Detergen Bubuk 1kg',
      description:
          'Detergen bubuk dengan wangi segar tahan lama, membersihkan noda membandel.',
      price: 28000,
      imageUrl: 'https://placehold.co/400x400/EC4899/FFFFFF?text=Detergen',
      category: ProductCategory.household,
      rating: 4.7,
      soldCount: 780,
    ),
    const Product(
      id: 'prod-006',
      name: 'Kipas Angin Portable',
      description:
          'Kipas angin mini portable dengan USB charging, cocok untuk bepergian.',
      price: 85000,
      originalPrice: 120000,
      imageUrl: 'https://placehold.co/400x400/06B6D4/FFFFFF?text=Kipas',
      category: ProductCategory.electronics,
      rating: 4.3,
      soldCount: 340,
    ),
    const Product(
      id: 'prod-007',
      name: 'Power Bank 10000mAh',
      description: 'Power bank kapasitas besar dengan fast charging support.',
      price: 150000,
      originalPrice: 180000,
      imageUrl: 'https://placehold.co/400x400/6366F1/FFFFFF?text=PowerBank',
      category: ProductCategory.electronics,
      rating: 4.6,
      soldCount: 520,
    ),
    const Product(
      id: 'prod-008',
      name: 'Kaos Polos Pria',
      description:
          'Kaos polos cotton combed 30s, nyaman dan adem untuk sehari-hari.',
      price: 45000,
      imageUrl: 'https://placehold.co/400x400/EF4444/FFFFFF?text=Kaos',
      category: ProductCategory.fashion,
      rating: 4.5,
      soldCount: 1890,
    ),
    const Product(
      id: 'prod-009',
      name: 'Vitamin C 1000mg',
      description:
          'Suplemen vitamin C untuk meningkatkan daya tahan tubuh. Isi 30 tablet.',
      price: 55000,
      imageUrl: 'https://placehold.co/400x400/84CC16/FFFFFF?text=VitC',
      category: ProductCategory.health,
      rating: 4.8,
      soldCount: 2450,
    ),
    const Product(
      id: 'prod-010',
      name: 'Masker Medis 50pcs',
      description: 'Masker medis 3 ply dengan filter yang efektif.',
      price: 35000,
      imageUrl: 'https://placehold.co/400x400/14B8A6/FFFFFF?text=Masker',
      category: ProductCategory.health,
      rating: 4.4,
      soldCount: 3200,
    ),
  ];
}
