import '../../../auth/data/models/auth_response_model.dart';

/// Response model for POST /login
/// Bila requires_otp=true: backend kirim OTP ke email, belum ada token.
/// Bila requires_otp=false: backend langsung kembalikan user + token.
class LoginResponseModel {
  const LoginResponseModel({
    required this.requiresOtp,
    this.email,
    this.expiresInMinutes,
    this.message,
    this.authResponse,
  });

  final bool requiresOtp;
  final String? email;
  final int? expiresInMinutes;
  final String? message;

  /// Jika requiresOtp=false, berisi user + token langsung
  final AuthResponseModel? authResponse;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final requiresOtp = (data['requires_otp'] as bool?) ?? true;
    if (!requiresOtp) {
      return LoginResponseModel(
        requiresOtp: false,
        authResponse: AuthResponseModel.fromJson(json),
      );
    }
    return LoginResponseModel(
      requiresOtp: true,
      email: (data['email'] as String?) ?? '',
      expiresInMinutes: (data['expires_in_minutes'] as int?) ?? 10,
      message: json['message'] as String?,
    );
  }
}
