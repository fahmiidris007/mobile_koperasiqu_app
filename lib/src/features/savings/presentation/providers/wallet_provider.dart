import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/data/datasources/mock_auth_datasource.dart';
import '../../data/datasources/wallet_datasource.dart';
import '../../domain/entities/wallet_info.dart';
import '../../domain/entities/wallet_transaction.dart';

// ── Singleton datasource ────────────────────────────────────────────────────

final _walletDatasource = WalletDatasource();

// ── GET /wallet → WalletInfo ────────────────────────────────────────────────

final walletProvider = FutureProvider.autoDispose<WalletInfo>((ref) async {
  return _walletDatasource.getWallet();
});

// ── GET /wallet/transactions → List<WalletTransaction> ─────────────────────

final walletTransactionsProvider =
    FutureProvider.autoDispose<List<WalletTransaction>>((ref) async {
      return _walletDatasource.getWalletTransactions();
    });

// ── POST /wallet/topup ──────────────────────────────────────────────────────

class TopupState {
  const TopupState({this.isLoading = false, this.error, this.result});

  final bool isLoading;
  final String? error;
  final TopupResult? result;

  TopupState copyWith({bool? isLoading, String? error, TopupResult? result}) {
    return TopupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class TopupNotifier extends StateNotifier<TopupState> {
  TopupNotifier(this._ref) : super(const TopupState());

  final Ref _ref;

  Future<TopupResult?> topup({required double amount}) async {
    state = state.copyWith(isLoading: true, error: null);

    // Generate random 3‑digit unique code (100–999), temporary now 200
    final uniqueCode = 200;
    // 100 + (DateTime.now().millisecondsSinceEpoch % 900);

    try {
      final result = await _walletDatasource.topup(
        amount: amount,
        uniqueCode: uniqueCode,
      );

      state = state.copyWith(isLoading: false, result: result);

      // Invalidate cached wallet data so balance & history refresh
      _ref.invalidate(walletProvider);
      _ref.invalidate(walletTransactionsProvider);

      return result;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal melakukan top up. Coba lagi.',
      );
      return null;
    }
  }

  void clearError() => state = state.copyWith(error: null);
  void clearResult() => state = const TopupState();
}

final topupNotifierProvider =
    StateNotifierProvider.autoDispose<TopupNotifier, TopupState>(
      (ref) => TopupNotifier(ref),
    );
