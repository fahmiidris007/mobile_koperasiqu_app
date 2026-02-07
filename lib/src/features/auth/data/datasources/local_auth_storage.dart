import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';

/// Service for storing user data locally using SharedPreferences
class LocalAuthStorage {
  static const String _usersKey = 'mock_users';
  static const String _currentUserKey = 'current_user_id';

  final SharedPreferences _prefs;

  LocalAuthStorage(this._prefs);

  /// Get all stored users as map (phone -> user data json)
  Map<String, Map<String, dynamic>> getUsers() {
    final jsonString = _prefs.getString(_usersKey);
    if (jsonString == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded.map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
    );
  }

  /// Save users map to local storage
  Future<void> saveUsers(Map<String, Map<String, dynamic>> users) async {
    await _prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Add or update a single user
  Future<void> saveUser(String phone, Map<String, dynamic> userData) async {
    final users = getUsers();
    users[phone] = userData;
    await saveUsers(users);
  }

  /// Get current logged in user id
  String? getCurrentUserId() {
    return _prefs.getString(_currentUserKey);
  }

  /// Set current logged in user id
  Future<void> setCurrentUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(_currentUserKey);
    } else {
      await _prefs.setString(_currentUserKey, userId);
    }
  }

  /// Clear all auth data (for logout/reset)
  Future<void> clear() async {
    await _prefs.remove(_usersKey);
    await _prefs.remove(_currentUserKey);
  }
}

/// User data model for JSON serialization
class StoredUserData {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String password;
  final String status;
  final String? memberId;
  final DateTime? joinDate;

  StoredUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.status,
    this.memberId,
    this.joinDate,
  });

  factory StoredUserData.fromJson(Map<String, dynamic> json) {
    return StoredUserData(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      status: json['status'] as String,
      memberId: json['memberId'] as String?,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'status': status,
      'memberId': memberId,
      'joinDate': joinDate?.toIso8601String(),
    };
  }

  UserStatus get userStatus {
    switch (status) {
      case 'approved':
        return UserStatus.approved;
      case 'pending':
        return UserStatus.pending;
      case 'rejected':
        return UserStatus.rejected;
      default:
        return UserStatus.pending;
    }
  }

  User toUser() {
    return User(
      id: id,
      name: name,
      phone: phone,
      email: email,
      status: userStatus,
      memberId: memberId,
      joinDate: joinDate,
    );
  }
}
