import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/user_datasource.dart';
import '../../domain/entities/user_stats.dart';

final _userDatasource = UserDatasource();

/// GET /user → User entity
final userProvider = FutureProvider.autoDispose<User>((ref) async {
  return _userDatasource.getUser();
});

/// GET /user/stats → UserStats entity
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  return _userDatasource.getUserStats();
});

// ── Update Profile ───────────────────────────────────────────────────────────

class UpdateProfileState {
  const UpdateProfileState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  UpdateProfileState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) => UpdateProfileState(
    isLoading: isLoading ?? this.isLoading,
    isSuccess: isSuccess ?? this.isSuccess,
    error: error,
  );
}

class UpdateProfileNotifier extends StateNotifier<UpdateProfileState> {
  UpdateProfileNotifier(this._ref) : super(const UpdateProfileState());
  final Ref _ref;

  Future<bool> save({
    String? name,
    String? email,
    String? phone,
    String? gender,
    bool? is2faEnabled,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _userDatasource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        is2faEnabled: is2faEnabled,
      );
      // Refresh user data
      _ref.invalidate(userProvider);
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const UpdateProfileState();
}

final updateProfileProvider =
    StateNotifierProvider.autoDispose<
      UpdateProfileNotifier,
      UpdateProfileState
    >((ref) => UpdateProfileNotifier(ref));
