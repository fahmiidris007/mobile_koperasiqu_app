import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/datasources/mock_auth_datasource.dart'
    show AuthException;

/// Model banner dari API GET /banners
class BannerModel {
  /// Base URL storage untuk resolve path gambar relatif
  static const String storageBaseUrl = 'https://koperasisjm.biz.id';

  const BannerModel({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.imageUrl,
    this.linkUrl,
    this.isActive,
    this.publishedAt,
  });

  final int id;
  final String title;

  /// Tipe banner: 'promo' atau 'news'
  final String type;
  final String? description;

  /// Full URL gambar (sudah di-resolve dari path relatif)
  final String? imageUrl;
  final String? linkUrl;
  final bool? isActive;
  final DateTime? publishedAt;

  bool get isPromo => type == 'promo';
  bool get isNews => type == 'news';
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory BannerModel.fromJson(Map<String, dynamic> j) {
    // Ambil path gambar — bisa dari field 'image_url' atau 'image'
    final rawImage = j['image_url']?.toString() ?? j['image']?.toString();

    // Resolve ke full URL jika path relatif (dimulai dengan '/')
    String? resolvedImage;
    if (rawImage != null && rawImage.isNotEmpty) {
      resolvedImage = rawImage.startsWith('http')
          ? rawImage
          : '$storageBaseUrl$rawImage';
    }

    return BannerModel(
      id: (j['id'] as num).toInt(),
      title: j['title']?.toString() ?? '',
      type: j['type']?.toString() ?? 'news',
      description: j['description']?.toString(),
      imageUrl: resolvedImage,
      linkUrl: j['link_url']?.toString() ?? j['link']?.toString(),
      isActive: j['is_active'] as bool? ?? true,
      publishedAt: j['published_at'] != null
          ? DateTime.tryParse(j['published_at'].toString())
          : null,
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
