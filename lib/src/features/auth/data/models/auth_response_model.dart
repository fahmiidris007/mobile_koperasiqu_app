import 'api_user_model.dart';
import '../../domain/entities/user.dart';

/// Response model for POST /login/verify-otp and POST /register
/// Both return { user, token }
class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.token,
    this.message,
  });

  final ApiUserModel user;
  final String token;
  final String? message;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return AuthResponseModel(
      user: ApiUserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: (data['token'] as String?) ?? '',
      message: json['message'] as String?,
    );
  }

  User toDomainUser() => user.toUser();
}
