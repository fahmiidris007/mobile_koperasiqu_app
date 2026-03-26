import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../data/datasources/shopping_datasource.dart';

final _shoppingDatasource = ShoppingDatasource();

// ── GET /categories ──────────────────────────────────────────────────────────

final categoriesProvider =
    FutureProvider.autoDispose<List<ApiCategory>>((ref) async {
  return _shoppingDatasource.getCategories();
});

// ── GET /products (all, optionally filtered by category slug) ─────────────────

final selectedCategorySlugProvider = StateProvider<String?>((ref) => null);

final productsApiProvider =
    FutureProvider.autoDispose<List<ApiProduct>>((ref) async {
  final slug = ref.watch(selectedCategorySlugProvider);
  return _shoppingDatasource.getProducts(categorySlug: slug);
});

// ── GET /products/featured ─────────────────────────────────────────────────

final featuredProductsProvider =
    FutureProvider.autoDispose<List<ApiProduct>>((ref) async {
  return _shoppingDatasource.getFeaturedProducts();
});

// ── GET /products/popular ──────────────────────────────────────────────────

final popularProductsProvider =
    FutureProvider.autoDispose<List<ApiProduct>>((ref) async {
  return _shoppingDatasource.getPopularProducts();
});

// ── GET /products/top-rated ────────────────────────────────────────────────

final topRatedProductsProvider =
    FutureProvider.autoDispose<List<ApiProduct>>((ref) async {
  return _shoppingDatasource.getTopRatedProducts();
});
