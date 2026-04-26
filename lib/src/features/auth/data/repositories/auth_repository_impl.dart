import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/login_response_model.dart';
import '../datasources/mock_auth_datasource.dart';

/// Mock implementation of AuthRepository using local persistence
/// Kept for reference/testing — replaced by ApiAuthRepositoryImpl in production
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl._internal(this._datasource);

  static AuthRepositoryImpl? _instance;

  static Future<AuthRepositoryImpl> getInstance() async {
    if (_instance == null) {
      final datasource = await MockAuthDatasource.getInstance();
      _instance = AuthRepositoryImpl._internal(datasource);
    }
    return _instance!;
  }

  static AuthRepositoryImpl get instance {
    if (_instance == null) {
      throw StateError(
        'AuthRepositoryImpl not initialized. Call getInstance() first.',
      );
    }
    return _instance!;
  }

  final MockAuthDatasource _datasource;

  @override
  Future<LoginResponseModel> loginWithResponse({
    required String email,
    required String password,
  }) async {
    // Mock: always requires OTP
    await _datasource.login(email: email, password: password);
    return LoginResponseModel(requiresOtp: true, email: email, expiresInMinutes: 10);
  }

  @override
  Future<void> login({required String email, required String password}) async {
    // Mock: just validate credentials without OTP flow
    await _datasource.login(email: email, password: password);
  }

  @override
  Future<User> verifyLoginOtp({
    required String email,
    required String code,
  }) async {
    // Mock: OTP always succeeds — return current user
    final user = await _datasource.getCurrentUser();
    if (user == null) throw AuthException('User tidak ditemukan');
    return user;
  }

  @override
  Future<User> register(RegistrationData data) {
    return _datasource.register(data);
  }

  @override
  Future<bool> isLoggedIn() {
    return _datasource.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() {
    return _datasource.getCurrentUser();
  }

  @override
  Future<void> logout() {
    return _datasource.logout();
  }

  @override
  Future<bool> verifyEkyc({
    required String ktpPhotoPath,
    required String selfiePhotoPath,
  }) {
    return _datasource.verifyEkyc(
      ktpPhotoPath: ktpPhotoPath,
      selfiePhotoPath: selfiePhotoPath,
    );
  }

  @override
  Future<UserStatus> checkRegistrationStatus(String userId) {
    return _datasource.checkRegistrationStatus(userId);
  }

  @override
  Future<void> sendRegisterOtp({required String email}) async {
    // Mock: no-op
  }

  @override
  Future<void> verifyRegisterOtp({
    required String email,
    required String code,
  }) async {
    // Mock: always succeeds
  }

  @override
  Future<void> resendOtp({required String email}) async {
    // Mock: no-op
  }
}
