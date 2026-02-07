import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';
import 'local_auth_storage.dart';

/// Mock data source for authentication with local persistence
/// Uses SharedPreferences to persist user data across app restarts
class MockAuthDatasource {
  // Singleton instance
  static MockAuthDatasource? _instance;

  static Future<MockAuthDatasource> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = MockAuthDatasource._internal(LocalAuthStorage(prefs));
      await _instance!._loadInitialData();
    }
    return _instance!;
  }

  // For synchronous access after initialization
  static MockAuthDatasource get instance {
    if (_instance == null) {
      throw StateError(
        'MockAuthDatasource not initialized. Call getInstance() first.',
      );
    }
    return _instance!;
  }

  final LocalAuthStorage _storage;

  MockAuthDatasource._internal(this._storage);

  // In-memory cache of users
  final Map<String, StoredUserData> _users = {};
  String? _currentUserId;

  /// Load initial data from local storage
  Future<void> _loadInitialData() async {
    // Load stored users from local storage
    final storedUsers = _storage.getUsers();
    for (final entry in storedUsers.entries) {
      _users[entry.key] = StoredUserData.fromJson(entry.value);
    }

    // Add default demo users if not exists
    if (!_users.containsKey('08123456789')) {
      final demoUser1 = StoredUserData(
        id: 'user-001',
        name: 'Ahmad Fahmi',
        phone: '08123456789',
        email: 'ahmad@email.com',
        password: '123456',
        status: 'approved',
        memberId: 'KQ-2024-001',
        joinDate: DateTime(2024, 1, 15),
      );
      _users['08123456789'] = demoUser1;
      await _storage.saveUser('08123456789', demoUser1.toJson());
    }

    if (!_users.containsKey('08111222333')) {
      final demoUser2 = StoredUserData(
        id: 'user-002',
        name: 'Siti Aisyah',
        phone: '08111222333',
        email: 'siti@email.com',
        password: '123456',
        status: 'pending',
        memberId: null,
        joinDate: null,
      );
      _users['08111222333'] = demoUser2;
      await _storage.saveUser('08111222333', demoUser2.toJson());
    }

    // Load current user id
    _currentUserId = _storage.getCurrentUserId();
  }

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
    await _storage.setCurrentUserId(userData.id);

    return userData.toUser();
  }

  /// Register new user (always returns pending)
  Future<User> register(RegistrationData data) async {
    await _simulateDelay();

    final cleanPhone = data.phone.replaceAll(RegExp(r'\D'), '');

    if (_users.containsKey(cleanPhone)) {
      throw AuthException('Nomor HP sudah terdaftar');
    }

    final userId = const Uuid().v4();
    final newUser = StoredUserData(
      id: userId,
      name: data.fullName,
      phone: cleanPhone,
      email: data.email,
      password: data.password,
      status: 'pending',
      memberId: null,
      joinDate: DateTime.now(),
    );

    _users[cleanPhone] = newUser;
    _currentUserId = userId;

    // Persist to local storage
    await _storage.saveUser(cleanPhone, newUser.toJson());
    await _storage.setCurrentUserId(userId);

    return newUser.toUser();
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

    return userData.toUser();
  }

  /// Logout
  Future<void> logout() async {
    await _simulateDelay();
    _currentUserId = null;
    await _storage.setCurrentUserId(null);
  }

  /// Simulate EKYC verification (always succeeds)
  Future<bool> verifyEkyc({
    required String ktpPhotoPath,
    required String selfiePhotoPath,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  /// Check registration status
  Future<UserStatus> checkRegistrationStatus(String userId) async {
    await _simulateDelay();

    final userData = _users.values.firstWhere(
      (u) => u.id == userId,
      orElse: () => throw AuthException('User not found'),
    );

    return userData.userStatus;
  }
}

/// Auth exception for error handling
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
