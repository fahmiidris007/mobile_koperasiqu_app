import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/datasources/mock_auth_datasource.dart' show AuthException;

/// Model banner dari API GET /banners
class BannerModel {
  const BannerModel({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.imageUrl,
    this.linkUrl,
    this.isActive,
  });

  final int id;
  final String title;

  /// Tipe banner: 'promo' atau 'news'
  final String type;
  final String? description;
  final String? imageUrl;
  final String? linkUrl;
  final bool? isActive;

  bool get isPromo => type == 'promo';
  bool get isNews => type == 'news';

  factory BannerModel.fromJson(Map<String, dynamic> j) {
    return BannerModel(
      id: (j['id'] as num).toInt(),
      title: j['title']?.toString() ?? '',
      type: j['type']?.toString() ?? 'promo',
      description: j['description']?.toString(),
      imageUrl: j['image_url']?.toString() ?? j['image']?.toString(),
      linkUrl: j['link_url']?.toString() ?? j['link']?.toString(),
      isActive: j['is_active'] as bool? ?? true,
    );
  }
}

/// Datasource untuk GET /banners
class BannerDatasource {
  Dio get _dio => ApiClient.instance;

  Future<List<BannerModel>> getBanners({String? type}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.banners,
        queryParameters: type != null ? {'type': type} : null,
      );
      final body = response.data as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>? ?? []);
      return list
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Return empty list jika 404 atau error API — banners belum tersedia
      if (e.response?.statusCode == 404) return [];
      throw AuthException(_parseError(e));
    } catch (_) {
      return [];
    }
  }

  String _parseError(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
      return 'Error ${response.statusCode}';
    }
    return 'Tidak dapat terhubung ke server.';
  }
}
