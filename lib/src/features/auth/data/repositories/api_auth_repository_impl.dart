import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/api_auth_datasource.dart';


/// Real implementation of AuthRepository using the backend API
class ApiAuthRepositoryImpl implements AuthRepository {
  ApiAuthRepositoryImpl() : _datasource = ApiAuthDatasource();

  final ApiAuthDatasource _datasource;

  @override
  Future<void> login({required String email, required String password}) async {
    // POST /login — backend sends OTP; we don't return a user yet
    await _datasource.login(email: email, password: password);
  }

  @override
  Future<User> verifyLoginOtp({
    required String email,
    required String code,
  }) {
    return _datasource.verifyLoginOtp(email: email, code: code);
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
  }) async {
    // EKYC is submitted as part of register() via multipart files
    // This is kept for compatibility; always returns true after register succeeds
    return true;
  }

  @override
  Future<UserStatus> checkRegistrationStatus(String userId) async {
    final user = await _datasource.getCurrentUser();
    return user?.status ?? UserStatus.pending;
  }

  @override
  Future<void> sendRegisterOtp({required String email}) {
    return _datasource.sendRegisterOtp(email: email);
  }

  @override
  Future<void> verifyRegisterOtp({
    required String email,
    required String code,
  }) {
    return _datasource.verifyRegisterOtp(email: email, code: code);
  }

  @override
  Future<void> resendOtp({required String email}) {
    return _datasource.resendOtp(email: email);
  }
}
