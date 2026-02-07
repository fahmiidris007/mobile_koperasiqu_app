import 'package:equatable/equatable.dart';

/// User entity representing an authenticated member
class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    this.avatarUrl,
    this.memberId,
    this.joinDate,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final UserStatus status;
  final String? avatarUrl;
  final String? memberId;
  final DateTime? joinDate;

  /// Check if user is fully approved and can access all features
  bool get isApproved => status == UserStatus.approved;

  /// Check if user is pending verification
  bool get isPending => status == UserStatus.pending;

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    status,
    avatarUrl,
    memberId,
    joinDate,
  ];

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserStatus? status,
    String? avatarUrl,
    String? memberId,
    DateTime? joinDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberId: memberId ?? this.memberId,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

/// User account status
enum UserStatus {
  /// Newly registered, awaiting document verification
  pending,

  /// Documents verified, awaiting admin approval
  underReview,

  /// Fully approved member
  approved,

  /// Account rejected or suspended
  rejected,
}

extension UserStatusX on UserStatus {
  String get displayName {
    switch (this) {
      case UserStatus.pending:
        return 'Menunggu Verifikasi';
      case UserStatus.underReview:
        return 'Dalam Peninjauan';
      case UserStatus.approved:
        return 'Aktif';
      case UserStatus.rejected:
        return 'Ditolak';
    }
  }
}
