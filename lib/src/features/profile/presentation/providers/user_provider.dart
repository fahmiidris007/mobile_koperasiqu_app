import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/user_datasource.dart';
import '../../domain/entities/user_stats.dart';

final _userDatasource = UserDatasource();

/// GET /user → User entity
final userProvider = FutureProvider.autoDispose<User>((ref) async {
  return _userDatasource.getUser();
});

/// GET /user/stats → UserStats entity
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  return _userDatasource.getUserStats();
});
