import '../entities/user.dart';
import '../entities/registration_data.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Login with phone and password
  /// Returns User on success, throws on failure
  Future<User> login({required String phone, required String password});

  /// Register a new member
  /// Returns User with pending status on success
  Future<User> register(RegistrationData data);

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Get current logged in user
  Future<User?> getCurrentUser();

  /// Logout current user
  Future<void> logout();

  /// Verify EKYC documents
  Future<bool> verifyEkyc({
    required String ktpPhotoPath,
    required String selfiePhotoPath,
  });

  /// Check registration status
  Future<UserStatus> checkRegistrationStatus(String userId);
}
