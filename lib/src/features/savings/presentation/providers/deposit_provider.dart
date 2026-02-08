import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/hive_transaction_storage.dart';

/// Deposit state - now uses Hive storage
class DepositState {
  const DepositState({
    this.balance = 0,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.lastAction,
  });

  final double balance;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;
  final String? lastAction;

  DepositState copyWith({
    double? balance,
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    String? lastAction,
  }) {
    return DepositState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastAction: lastAction,
    );
  }

  /// Get deposit/withdrawal transactions only
  List<TransactionModel> get depositWithdrawalTransactions => transactions
      .where(
        (t) =>
            t.type == TransactionType.deposit ||
            t.type == TransactionType.withdrawal,
      )
      .toList();
}

/// Deposit notifier using Hive storage
class DepositNotifier extends StateNotifier<DepositState> {
  DepositNotifier() : super(const DepositState()) {
    _init();
  }

  HiveTransactionStorage? _storage;

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      _storage = await HiveTransactionStorage.getInstance();

      final balance = _storage!.getBalance();
      final transactions = _storage!.getTransactions();

      state = state.copyWith(
        balance: balance,
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh data from storage
  Future<void> refresh() async {
    if (_storage == null) {
      await _init();
      return;
    }

    final balance = _storage!.getBalance();
    final transactions = _storage!.getTransactions();

    state = state.copyWith(balance: balance, transactions: transactions);
  }

  /// Create a new deposit
  Future<bool> createDeposit({
    required double amount,
    required String description,
  }) async {
    if (_storage == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _storage!.createDeposit(amount: amount, description: description);

      state = state.copyWith(
        balance: _storage!.getBalance(),
        transactions: _storage!.getTransactions(),
        isLoading: false,
        lastAction: 'deposit_created',
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Create a new withdrawal
  Future<bool> createWithdrawal({
    required double amount,
    required String description,
  }) async {
    if (_storage == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _storage!.createWithdrawal(
        amount: amount,
        description: description,
      );

      state = state.copyWith(
        balance: _storage!.getBalance(),
        transactions: _storage!.getTransactions(),
        isLoading: false,
        lastAction: 'withdrawal_created',
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Update a deposit/transaction
  Future<bool> updateDeposit({
    required String id,
    double? amount,
    String? description,
  }) async {
    if (_storage == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updated = await _storage!.updateTransaction(
        id: id,
        amount: amount,
        description: description,
      );

      if (updated == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Transaksi tidak ditemukan',
        );
        return false;
      }

      state = state.copyWith(
        balance: _storage!.getBalance(),
        transactions: _storage!.getTransactions(),
        isLoading: false,
        lastAction: 'deposit_updated',
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a deposit/transaction
  Future<bool> deleteDeposit(String id) async {
    if (_storage == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _storage!.deleteTransaction(id);

      state = state.copyWith(
        balance: _storage!.getBalance(),
        transactions: _storage!.getTransactions(),
        isLoading: false,
        lastAction: 'deposit_deleted',
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Get transaction by ID
  TransactionModel? getTransactionById(String id) {
    return _storage?.getTransactionById(id);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for deposit state (uses Hive storage)
final depositProvider = StateNotifierProvider<DepositNotifier, DepositState>(
  (ref) => DepositNotifier(),
);
