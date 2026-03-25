import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/datasources/mock_auth_datasource.dart' show AuthException;
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/user_stats.dart';

/// Datasource for GET /user and GET /user/stats
class UserDatasource {
  Dio get _dio => ApiClient.instance;

  Future<User> getUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.user);
      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return _userFromJson(data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<UserStats> getUserStats() async {
    try {
      final response = await _dio.get(ApiEndpoints.userStats);
      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return _statsFromJson(data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  User _userFromJson(Map<String, dynamic> j) {
    return User(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      phone: j['phone']?.toString() ?? '',
      status: UserStatus.approved,
      avatarUrl: j['photo_url']?.toString(),
      joinDate: DateTime.tryParse(j['created_at']?.toString() ?? ''),
    );
  }

  UserStats _statsFromJson(Map<String, dynamic> j) {
    return UserStats(
      totalTransactions: (j['total_transactions'] as num? ?? 0).toInt(),
      totalSpent: (j['total_spent'] as num? ?? 0).toDouble(),
      totalSpentFormatted: j['total_spent_formatted']?.toString() ?? 'Rp 0',
      transactionsThisMonth:
          (j['transactions_this_month'] as num? ?? 0).toInt(),
      spentThisMonth: (j['spent_this_month'] as num? ?? 0).toDouble(),
      spentThisMonthFormatted:
          j['spent_this_month_formatted']?.toString() ?? 'Rp 0',
      averagePerTransactionFormatted:
          j['average_per_transaction_formatted']?.toString() ?? 'Rp 0',
      memberSince: DateTime.tryParse(j['member_since']?.toString() ?? '') ??
          DateTime.now(),
      memberDays: (j['member_days'] as num? ?? 0).toDouble(),
    );
  }

  String _parseError(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map) {
        if (body['message'] != null) return body['message'].toString();
      }
      return 'Error ${response.statusCode}';
    }
    return 'Tidak dapat terhubung ke server.';
  }
}
