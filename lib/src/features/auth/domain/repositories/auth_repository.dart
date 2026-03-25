import '../entities/user.dart';
import '../entities/registration_data.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Login with email and password — triggers OTP sent to email
  Future<void> login({required String email, required String password});

  /// Verify OTP after login — returns authenticated User + saves token
  Future<User> verifyLoginOtp({required String email, required String code});

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

  // ── OTP for registration verification ─────────────────────────────────────

  /// Send OTP email for registration verification
  Future<void> sendRegisterOtp({required String email});

  /// Verify registration OTP
  Future<void> verifyRegisterOtp({
    required String email,
    required String code,
  });

  /// Resend registration OTP
  Future<void> resendOtp({required String email});
}
