import 'package:uuid/uuid.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';

/// Mock data source for authentication (no backend)
class MockAuthDatasource {
  MockAuthDatasource();

  // Simulated user storage
  final Map<String, _MockUserData> _users = {
    '08123456789': _MockUserData(
      id: 'user-001',
      name: 'Ahmad Fahmi',
      phone: '08123456789',
      email: 'ahmad@email.com',
      password: '123456',
      status: UserStatus.approved,
      memberId: 'KQ-2024-001',
      joinDate: DateTime(2024, 1, 15),
    ),
    '08111222333': _MockUserData(
      id: 'user-002',
      name: 'Siti Aisyah',
      phone: '08111222333',
      email: 'siti@email.com',
      password: '123456',
      status: UserStatus.pending,
      memberId: null,
      joinDate: null,
    ),
  };

  String? _currentUserId;

  /// Simulate login delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Login with phone and password
  Future<User> login({required String phone, required String password}) async {
    await _simulateDelay();

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final userData = _users[cleanPhone];

    if (userData == null) {
      throw AuthException('Nomor HP tidak terdaftar');
    }

    if (userData.password != password) {
      throw AuthException('Password salah');
    }

    _currentUserId = userData.id;

    return User(
      id: userData.id,
      name: userData.name,
      phone: userData.phone,
      email: userData.email,
      status: userData.status,
      memberId: userData.memberId,
      joinDate: userData.joinDate,
    );
  }

  /// Register new user (always returns pending)
  Future<User> register(RegistrationData data) async {
    await _simulateDelay();

    final cleanPhone = data.phone.replaceAll(RegExp(r'\D'), '');

    if (_users.containsKey(cleanPhone)) {
      throw AuthException('Nomor HP sudah terdaftar');
    }

    final userId = const Uuid().v4();
    final newUser = _MockUserData(
      id: userId,
      name: data.fullName,
      phone: cleanPhone,
      email: data.email,
      password: data.password,
      status: UserStatus.pending,
      memberId: null,
      joinDate: DateTime.now(),
    );

    _users[cleanPhone] = newUser;
    _currentUserId = userId;

    return User(
      id: newUser.id,
      name: newUser.name,
      phone: newUser.phone,
      email: newUser.email,
      status: newUser.status,
      joinDate: newUser.joinDate,
    );
  }

  /// Check if logged in
  Future<bool> isLoggedIn() async {
    return _currentUserId != null;
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    if (_currentUserId == null) return null;

    final userData = _users.values.firstWhere(
      (u) => u.id == _currentUserId,
      orElse: () => throw AuthException('User not found'),
    );

    return User(
      id: userData.id,
      name: userData.name,
      phone: userData.phone,
      email: userData.email,
      status: userData.status,
      memberId: userData.memberId,
      joinDate: userData.joinDate,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _simulateDelay();
    _currentUserId = null;
  }

  /// Simulate EKYC verification (always succeeds)
  Future<bool> verifyEkyc({
    required String ktpPhotoPath,
    required String selfiePhotoPath,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    // In a real app, this would call VIDA API
    return true;
  }

  /// Check registration status
  Future<UserStatus> checkRegistrationStatus(String userId) async {
    await _simulateDelay();

    final userData = _users.values.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw AuthException('User not found'),
    );

    return userData.status;
  }
}

/// Internal mock user data holder
class _MockUserData {
  _MockUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.status,
    this.memberId,
    this.joinDate,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String password;
  final UserStatus status;
  final String? memberId;
  final DateTime? joinDate;
}

/// Auth exception for error handling
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
