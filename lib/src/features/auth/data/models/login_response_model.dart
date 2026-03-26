/// Response model for POST /login
/// Backend sends OTP to email, does NOT return a token yet.
class LoginResponseModel {
  const LoginResponseModel({
    required this.requiresOtp,
    required this.email,
    required this.expiresInMinutes,
    this.message,
  });

  final bool requiresOtp;
  final String email;
  final int expiresInMinutes;
  final String? message;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return LoginResponseModel(
      requiresOtp: (data['requires_otp'] as bool?) ?? true,
      email: (data['email'] as String?) ?? '',
      expiresInMinutes: (data['expires_in_minutes'] as int?) ?? 10,
      message: json['message'] as String?,
    );
  }
}
