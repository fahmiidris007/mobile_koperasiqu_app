import '../../domain/entities/user.dart';

/// API response model for user data returned by backend
class ApiUserModel {
  const ApiUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    this.photoUrl,
    this.emailVerifiedAt,
    required this.roles,
    required this.walletBalance,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String? photoUrl;
  final String? emailVerifiedAt;
  final List<String> roles;
  final double walletBalance;
  final String createdAt;

  factory ApiUserModel.fromJson(Map<String, dynamic> json) {
    return ApiUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: (json['phone'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? 'male',
      photoUrl: json['photo_url'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      roles: List<String>.from((json['roles'] as List?) ?? []),
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  /// Convert to domain entity
  User toUser() {
    // User is approved when email_verified_at is not null
    // or when roles contain 'admin' or 'approved'
    final isApproved = emailVerifiedAt != null;

    return User(
      id: id.toString(),
      name: name,
      email: email,
      phone: phone,
      memberId: isApproved ? 'KQ-$id' : null,
      status: isApproved ? UserStatus.approved : UserStatus.pending,
      joinDate: DateTime.tryParse(createdAt),
      avatarUrl: photoUrl,
    );
  }
}
