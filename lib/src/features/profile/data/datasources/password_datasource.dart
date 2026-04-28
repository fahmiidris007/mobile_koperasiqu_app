import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/datasources/mock_auth_datasource.dart' show AuthException;

/// Datasource untuk operasi password (forgot, reset, change)
class PasswordDatasource {
  Dio get _dio => ApiClient.instance;

  /// POST /password/forgot — kirim email untuk reset password
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// POST /password/reset — reset password dengan kode OTP
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// POST /user/change-password — ganti password dari dalam app (terautentikasi)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map) {
        if (body['errors'] != null) {
          final errors = body['errors'] as Map;
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        if (body['message'] != null) return body['message'].toString();
      }
      return 'Error ${response.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    return 'Tidak dapat terhubung ke server.';
  }
}
