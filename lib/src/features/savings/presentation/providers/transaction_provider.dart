import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/hive_transaction_storage.dart';

/// Transaction state
class TransactionState {
  const TransactionState({
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

  TransactionState copyWith({
    double? balance,
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
    String? lastAction,
  }) {
    return TransactionState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastAction: lastAction,
    );
  }

  /// Get recent transactions for dashboard (top 5)
  List<TransactionModel> get recentTransactions =>
      transactions.take(5).toList();
}

/// Transaction notifier for state management
class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(const TransactionState()) {
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

  /// Update a transaction
  Future<bool> updateTransaction({
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
        lastAction: 'transaction_updated',
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(String id) async {
    if (_storage == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _storage!.deleteTransaction(id);

      state = state.copyWith(
        balance: _storage!.getBalance(),
        transactions: _storage!.getTransactions(),
        isLoading: false,
        lastAction: 'transaction_deleted',
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for transaction state
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
      (ref) => TransactionNotifier(),
    );
