import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/banner_datasource.dart';

/// Provider untuk semua banners
final bannerProvider = FutureProvider<List<BannerModel>>((ref) async {
  return BannerDatasource().getBanners();
});

/// Provider untuk banners tipe 'promo'
final promoBannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final all = await ref.watch(bannerProvider.future);
  return all.where((b) => b.isPromo).toList();
});

/// Provider untuk banners tipe 'news'
final newsBannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final all = await ref.watch(bannerProvider.future);
  return all.where((b) => b.isNews).toList();
});
