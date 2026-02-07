import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_auth_datasource.dart';

/// Implementation of AuthRepository using mock data source
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({MockAuthDatasource? datasource})
    : _datasource = datasource ?? MockAuthDatasource();

  final MockAuthDatasource _datasource;

  @override
  Future<User> login({required String phone, required String password}) {
    return _datasource.login(phone: phone, password: password);
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
}
