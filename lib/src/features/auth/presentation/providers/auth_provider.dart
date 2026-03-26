import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';
import '../../data/repositories/api_auth_repository_impl.dart';
import '../../data/datasources/mock_auth_datasource.dart' show AuthException;

export '../../data/repositories/api_auth_repository_impl.dart'
    show ApiAuthRepositoryImpl;

// ── States ─────────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final User user;
}

class AuthPending extends AuthState {
  const AuthPending(this.user);
  final User user;
}

/// New state: login credentials OK, OTP sent to email — awaiting OTP entry
class AuthOtpRequired extends AuthState {
  const AuthOtpRequired(this.email);
  final String email;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ── AuthNotifier ──────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial());

  final ApiAuthRepositoryImpl _repository;

  /// Check initial auth state on app start
  Future<void> checkAuthState() async {
    state = const AuthLoading();
    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          state = user.isApproved ? AuthAuthenticated(user) : AuthPending(user);
          return;
        }
      }
      state = const AuthUnauthenticated();
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  /// Step 1 login: validates credentials, triggers OTP email
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      await _repository.login(email: email, password: password);
      // Backend sent OTP — transition to OTP step
      state = AuthOtpRequired(email);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  /// Step 2 login: verifies OTP and completes authentication
  Future<void> verifyLoginOtp(String email, String code) async {
    state = const AuthLoading();
    try {
      final user = await _repository.verifyLoginOtp(email: email, code: code);
      // state = user.isApproved ? AuthAuthenticated(user) : AuthPending(user);
      state = AuthAuthenticated(user);
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (_) {
      state = const AuthError('Verifikasi OTP gagal. Silakan coba lagi.');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  /// Clear error state
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

// ── Registration State ─────────────────────────────────────────────────────

class RegistrationState {
  const RegistrationState({
    this.data = const RegistrationData(),
    this.isLoading = false,
    this.error,
    this.isComplete = false,
  });

  final RegistrationData data;
  final bool isLoading;
  final String? error;
  final bool isComplete;

  RegistrationState copyWith({
    RegistrationData? data,
    bool? isLoading,
    String? error,
    bool? isComplete,
  }) {
    return RegistrationState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

// ── RegistrationNotifier ───────────────────────────────────────────────────

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier(this._repository) : super(const RegistrationState());

  final ApiAuthRepositoryImpl _repository;

  void updateData(RegistrationData data) {
    state = state.copyWith(data: data);
  }

  void nextStep() {
    state = state.copyWith(
      data: state.data.copyWith(currentStep: state.data.currentStep + 1),
    );
  }

  void previousStep() {
    if (state.data.currentStep > 0) {
      state = state.copyWith(
        data: state.data.copyWith(currentStep: state.data.currentStep - 1),
      );
    }
  }

  /// Submit registration (calls API via repository)
  Future<User?> submit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.register(state.data);
      state = state.copyWith(isLoading: false, isComplete: true);
      return user;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan. Silakan coba lagi.',
      );
      return null;
    }
  }

  /// Verify EKYC (file paths already embedded in RegistrationData)
  Future<bool> verifyEkyc(String ktpPath, String selfiePath) async {
    state = state.copyWith(
      isLoading: true,
      data: state.data.copyWith(
        ktpPhotoPath: ktpPath,
        selfiePhotoPath: selfiePath,
      ),
    );
    try {
      await _repository.verifyEkyc(
        ktpPhotoPath: ktpPath,
        selfiePhotoPath: selfiePath,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Verifikasi gagal. Silakan coba lagi.',
      );
      return false;
    }
  }

  // ── OTP helpers (called from register flow UI) ──────────────────────────

  Future<void> sendRegisterOtp(String email) async {
    try {
      await _repository.sendRegisterOtp(email: email);
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'Gagal mengirim OTP.');
    }
  }

  Future<bool> verifyRegisterOtp(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.verifyRegisterOtp(email: email, code: code);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Kode OTP tidak valid.');
      return false;
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      await _repository.resendOtp(email: email);
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'Gagal mengirim ulang OTP.');
    }
  }

  void reset() {
    state = const RegistrationState();
  }
}

// ── Providers ──────────────────────────────────────────────────────────────

/// Repository provider — override at app startup with ApiAuthRepositoryImpl
final authRepositoryProvider = Provider<ApiAuthRepositoryImpl>((ref) {
  return ApiAuthRepositoryImpl();
});

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Registration provider
final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return RegistrationNotifier(repository);
    });
