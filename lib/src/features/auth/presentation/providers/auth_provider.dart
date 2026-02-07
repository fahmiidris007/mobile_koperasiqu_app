import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/registration_data.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/mock_auth_datasource.dart';

/// Auth state
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

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthInitial());

  final AuthRepositoryImpl _repository;

  /// Check initial auth state
  Future<void> checkAuthState() async {
    state = const AuthLoading();

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _repository.getCurrentUser();
        if (user != null) {
          if (user.isApproved) {
            state = AuthAuthenticated(user);
          } else {
            state = AuthPending(user);
          }
          return;
        }
      }
      state = const AuthUnauthenticated();
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  /// Login with phone and password
  Future<void> login(String phone, String password) async {
    state = const AuthLoading();

    try {
      final user = await _repository.login(phone: phone, password: password);

      if (user.isApproved) {
        state = AuthAuthenticated(user);
      } else {
        state = AuthPending(user);
      }
    } on AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = const AuthError('Terjadi kesalahan. Silakan coba lagi.');
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

/// Registration state
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

/// Registration notifier for multi-step form
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier(this._repository) : super(const RegistrationState());

  final AuthRepositoryImpl _repository;

  /// Update registration data
  void updateData(RegistrationData data) {
    state = state.copyWith(data: data);
  }

  /// Go to next step
  void nextStep() {
    state = state.copyWith(
      data: state.data.copyWith(currentStep: state.data.currentStep + 1),
    );
  }

  /// Go to previous step
  void previousStep() {
    if (state.data.currentStep > 0) {
      state = state.copyWith(
        data: state.data.copyWith(currentStep: state.data.currentStep - 1),
      );
    }
  }

  /// Submit registration
  Future<User?> submit() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _repository.register(state.data);
      state = state.copyWith(isLoading: false, isComplete: true);
      return user;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Terjadi kesalahan. Silakan coba lagi.',
      );
      return null;
    }
  }

  /// Verify EKYC
  Future<bool> verifyEkyc(String ktpPath, String selfiePath) async {
    state = state.copyWith(
      isLoading: true,
      data: state.data.copyWith(
        ktpPhotoPath: ktpPath,
        selfiePhotoPath: selfiePath,
      ),
    );

    try {
      final success = await _repository.verifyEkyc(
        ktpPhotoPath: ktpPath,
        selfiePhotoPath: selfiePath,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Verifikasi gagal. Silakan coba lagi.',
      );
      return false;
    }
  }

  /// Reset registration
  void reset() {
    state = const RegistrationState();
  }
}

/// Provider for the auth repository (must be overridden at app startup)
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden');
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
