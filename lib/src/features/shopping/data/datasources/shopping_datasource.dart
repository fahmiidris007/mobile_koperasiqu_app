import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/datasources/mock_auth_datasource.dart' show AuthException;
import '../../domain/entities/product.dart';

/// Real API datasource for shopping: products & categories
class ShoppingDatasource {
  Dio get _dio => ApiClient.instance;

  // ── GET /categories ─────────────────────────────────────────────────────────

  Future<List<ApiCategory>> getCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.categories);
      final data = (response.data as Map<String, dynamic>)['data'] as List;
      return data.map((e) => _categoryFromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── GET /products ───────────────────────────────────────────────────────────

  Future<List<ApiProduct>> getProducts({String? categorySlug}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.products,
        queryParameters: categorySlug != null ? {'category': categorySlug} : null,
      );
      return _extractProducts(response.data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── GET /products/featured ──────────────────────────────────────────────────

  Future<List<ApiProduct>> getFeaturedProducts() async {
    try {
      final response = await _dio.get(ApiEndpoints.featuredProducts);
      return _extractProducts(response.data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── GET /products/popular ──────────────────────────────────────────────────

  Future<List<ApiProduct>> getPopularProducts() async {
    try {
      final response = await _dio.get(ApiEndpoints.popularProducts);
      return _extractProducts(response.data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── GET /products/top-rated ─────────────────────────────────────────────────

  Future<List<ApiProduct>> getTopRatedProducts() async {
    try {
      final response = await _dio.get(ApiEndpoints.topRatedProducts);
      return _extractProducts(response.data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── POST /products/:id_slug/click ──────────────────────────────────────────

  /// Record product interest. Fire-and-forget — error tidak di-throw.
  Future<void> recordProductClick(String idOrSlug) async {
    try {
      await _dio.post(ApiEndpoints.productClick(idOrSlug));
    } catch (_) {
      // Intentionally silent — click tracking is non-critical
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List<ApiProduct> _extractProducts(dynamic responseData) {
    final root = responseData as Map<String, dynamic>;
    final data = root['data'];
    List rawList;
    if (data is Map && data.containsKey('products')) {
      rawList = data['products'] as List;
    } else if (data is List) {
      rawList = data;
    } else {
      rawList = [];
    }
    return rawList.map((e) => _productFromJson(e as Map<String, dynamic>)).toList();
  }

  ApiCategory _categoryFromJson(Map<String, dynamic> j) {
    return ApiCategory(
      id: (j['id'] as num).toInt(),
      name: j['name']?.toString() ?? '',
      slug: j['slug']?.toString() ?? '',
      productsCount: (j['products_count'] as num? ?? 0).toInt(),
    );
  }

  ApiProduct _productFromJson(Map<String, dynamic> j) {
    final catJson = j['category'] as Map<String, dynamic>? ?? {};
    return ApiProduct(
      id: (j['id'] as num).toInt(),
      name: j['name']?.toString() ?? '',
      slug: j['slug']?.toString() ?? '',
      price: (j['price'] as num).toDouble(),
      priceFormatted: j['price_formatted']?.toString() ?? '',
      rate: (j['rate'] as num? ?? 0).toDouble(),
      thumbnailUrl: j['thumbnail_url']?.toString(),
      serviceTime: (j['service_time'] as num? ?? 0).toInt(),
      isFeatured: j['is_featured'] as bool? ?? false,
      category: ApiCategory(
        id: (catJson['id'] as num? ?? 0).toInt(),
        name: catJson['name']?.toString() ?? '',
        slug: catJson['slug']?.toString() ?? '',
      ),
    );
  }

  String _parseError(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map && body['message'] != null) return body['message'].toString();
      return 'Error ${response.statusCode}';
    }
    return 'Tidak dapat terhubung ke server.';
  }
}
