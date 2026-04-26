import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';
import '../models/api_user_model.dart';
import '../models/login_response_model.dart';
import '../models/auth_response_model.dart';
import 'mock_auth_datasource.dart'; // re-use AuthException

/// Real API datasource — calls backend endpoints
class ApiAuthDatasource {
  Dio get _dio => ApiClient.instance;

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// POST /login — kembalikan LoginResponseModel
  /// Jika requires_otp=false, token langsung disimpan.
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
        options: Options(contentType: 'application/json'),
      );
      final model = LoginResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      // Jika 2FA tidak aktif, token sudah tersedia — simpan sekarang
      if (!model.requiresOtp && model.authResponse != null) {
        await TokenStorage.saveToken(model.authResponse!.token);
      }
      return model;
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// POST /login/verify-otp — verifies OTP and returns user + token
  Future<User> verifyLoginOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyLoginOtp,
        data: {'email': email, 'code': code},
        options: Options(contentType: 'application/json'),
      );
      final model = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      // Persist token for subsequent authenticated calls
      await TokenStorage.saveToken(model.token);
      return model.toDomainUser();
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// POST /register — multipart form-data with optional photo files
  Future<User> register(RegistrationData data) async {
    try {
      final formData = FormData.fromMap({
        'name': data.fullName,
        'email': data.email,
        'password': data.password,
        'password_confirmation': data.password,
        'phone': data.phone,
        'gender': _genderToApi(data.gender),
        'nik': data.nik,
        'birth_date': _formatDate(data.birthDate),
        'job': data.occupation,
        'office_name': data.companyName,
        'positions': data.jobPosition,
        'salary': data.monthlyIncome.toString(),
        'marital': _maritalToApi(data.maritalStatus),
        'kids': data.numberOfChildren.toString(),
        // File uploads (selfie = photo, KTP = ktp_photo)
        if (data.selfiePhotoPath.isNotEmpty)
          'photo': await MultipartFile.fromFile(
            data.selfiePhotoPath,
            filename: 'selfie.jpg',
          ),
        if (data.ktpPhotoPath.isNotEmpty)
          'ktp_photo': await MultipartFile.fromFile(
            data.ktpPhotoPath,
            filename: 'ktp.jpg',
          ),
      });

      final response = await _dio.post(ApiEndpoints.register, data: formData);
      final model = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      // Persist token received after register
      await TokenStorage.saveToken(model.token);
      return model.toDomainUser();
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── OTP (register verification) ───────────────────────────────────────────

  /// POST /otp/send — send OTP to email after registration
  Future<void> sendRegisterOtp({required String email}) async {
    try {
      await _dio.post(
        ApiEndpoints.sendOtp,
        data: {'email': email},
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// POST /otp/verify — verify register OTP
  Future<void> verifyRegisterOtp({
    required String email,
    required String code,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'code': code},
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// POST /otp/resend
  Future<void> resendOtp({required String email}) async {
    try {
      await _dio.post(
        ApiEndpoints.resendOtp,
        data: {'email': email},
        options: Options(contentType: 'application/json'),
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── Session ───────────────────────────────────────────────────────────────

  /// GET /user — fetch current authenticated user
  Future<User?> getCurrentUser() async {
    final hasToken = await TokenStorage.hasToken();
    if (!hasToken) return null;

    try {
      final response = await _dio.get(ApiEndpoints.user);
      final data = response.data as Map<String, dynamic>;
      final userJson = data['data'] as Map<String, dynamic>;
      return ApiUserModel.fromJson(userJson).toUser();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await TokenStorage.deleteToken();
        return null;
      }
      throw AuthException(_parseError(e));
    }
  }

  Future<bool> isLoggedIn() async {
    return TokenStorage.hasToken();
  }

  Future<void> logout() async {
    // Panggil API logout terlebih dahulu untuk invalidate token di server
    try {
      await _dio.post(
        ApiEndpoints.logout,
        options: Options(headers: {'Accept': 'application/json'}),
      );
    } catch (_) {
      // Jika API gagal (misal offline/expired), tetap hapus token lokal
    }
    await TokenStorage.deleteToken();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Extract a user-friendly error message from DioException
  String _parseError(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map) {
        // Laravel validation errors: { errors: { field: ['msg'] } }
        if (body['errors'] != null) {
          final errors = body['errors'] as Map;
          final firstField = errors.values.first;
          if (firstField is List && firstField.isNotEmpty) {
            return firstField.first.toString();
          }
        }
        // Simple message
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

  String _genderToApi(Gender? gender) {
    if (gender == Gender.female) return 'female';
    return 'male';
  }

  String _maritalToApi(MaritalStatus? status) {
    switch (status) {
      case MaritalStatus.married:
        return 'married';
      case MaritalStatus.divorced:
        return 'divorced';
      case MaritalStatus.widowed:
        return 'widowed';
      default:
        return 'single';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
