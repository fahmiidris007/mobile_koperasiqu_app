import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Transaction type enum
enum TransactionType {
  deposit,
  withdrawal,
  interest,
  cashback,
  transfer,
  purchase,
}

/// Transaction model for Hive storage
class TransactionModel {
  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
    required this.balanceAfter,
    this.category,
  });

  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionType type;
  final double balanceAfter;
  final String? category;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.name,
      'balanceAfter': balanceAfter,
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.deposit,
      ),
      balanceAfter: (map['balanceAfter'] as num).toDouble(),
      category: map['category'] as String?,
    );
  }

  bool get isCredit =>
      type == TransactionType.deposit ||
      type == TransactionType.interest ||
      type == TransactionType.cashback;

  bool get isDebit =>
      type == TransactionType.withdrawal ||
      type == TransactionType.transfer ||
      type == TransactionType.purchase;
}

/// Hive-based transaction storage service
class HiveTransactionStorage {
  static const String _transactionsBox = 'transactions';
  static const String _balanceBox = 'balance';
  static const String _balanceKey = 'current_balance';

  static HiveTransactionStorage? _instance;
  late Box<Map> _txBox;
  late Box<double> _balanceBoxRef;
  bool _isInitialized = false;

  HiveTransactionStorage._();

  static Future<HiveTransactionStorage> getInstance() async {
    if (_instance == null) {
      _instance = HiveTransactionStorage._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _txBox = await Hive.openBox<Map>(_transactionsBox);
    _balanceBoxRef = await Hive.openBox<double>(_balanceBox);

    // Initialize with default balance if empty
    if (_balanceBoxRef.get(_balanceKey) == null) {
      await _balanceBoxRef.put(_balanceKey, 15750000.0);

      // Add some initial demo transactions
      await _addDemoTransactions();
    }

    _isInitialized = true;
  }

  Future<void> _addDemoTransactions() async {
    final now = DateTime.now();
    final demoTransactions = [
      TransactionModel(
        id: const Uuid().v4(),
        amount: 500000,
        description: 'Setoran Bulanan',
        date: now.subtract(const Duration(hours: 2)),
        type: TransactionType.deposit,
        balanceAfter: 15750000,
      ),
      TransactionModel(
        id: const Uuid().v4(),
        amount: 45000,
        description: 'Bunga Desember 2024',
        date: now.subtract(const Duration(days: 1)),
        type: TransactionType.interest,
        balanceAfter: 15250000,
      ),
      TransactionModel(
        id: const Uuid().v4(),
        amount: 1000000,
        description: 'Setoran THR',
        date: now.subtract(const Duration(days: 7)),
        type: TransactionType.deposit,
        balanceAfter: 15205000,
      ),
      TransactionModel(
        id: const Uuid().v4(),
        amount: 500000,
        description: 'Penarikan Tunai',
        date: now.subtract(const Duration(days: 14)),
        type: TransactionType.withdrawal,
        balanceAfter: 14205000,
      ),
      TransactionModel(
        id: const Uuid().v4(),
        amount: 250000,
        description: 'Belanja Koperasi',
        date: now.subtract(const Duration(days: 21)),
        type: TransactionType.purchase,
        balanceAfter: 14705000,
      ),
      TransactionModel(
        id: const Uuid().v4(),
        amount: 25000,
        description: 'Cashback Belanja',
        date: now.subtract(const Duration(days: 22)),
        type: TransactionType.cashback,
        balanceAfter: 14955000,
      ),
    ];

    for (final tx in demoTransactions) {
      await _txBox.put(tx.id, tx.toMap());
    }
  }

  /// Get current balance
  double getBalance() {
    return _balanceBoxRef.get(_balanceKey) ?? 15750000.0;
  }

  /// Save balance
  Future<void> saveBalance(double balance) async {
    await _balanceBoxRef.put(_balanceKey, balance);
  }

  /// Get all transactions sorted by date (newest first)
  List<TransactionModel> getTransactions({int? limit}) {
    final transactions =
        _txBox.values.map((e) => TransactionModel.fromMap(e)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && transactions.length > limit) {
      return transactions.take(limit).toList();
    }
    return transactions;
  }

  /// Get recent transactions for dashboard
  List<TransactionModel> getRecentTransactions({int limit = 5}) {
    return getTransactions(limit: limit);
  }

  /// Get transaction by ID
  TransactionModel? getTransactionById(String id) {
    final map = _txBox.get(id);
    if (map == null) return null;
    return TransactionModel.fromMap(map);
  }

  /// Create a deposit
  Future<TransactionModel> createDeposit({
    required double amount,
    required String description,
  }) async {
    final currentBalance = getBalance();
    final newBalance = currentBalance + amount;

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      description: description,
      date: DateTime.now(),
      type: TransactionType.deposit,
      balanceAfter: newBalance,
    );

    await _txBox.put(transaction.id, transaction.toMap());
    await saveBalance(newBalance);

    return transaction;
  }

  /// Create a withdrawal
  Future<TransactionModel> createWithdrawal({
    required double amount,
    required String description,
  }) async {
    final currentBalance = getBalance();

    if (amount > currentBalance) {
      throw Exception('Saldo tidak mencukupi');
    }

    final newBalance = currentBalance - amount;

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      description: description,
      date: DateTime.now(),
      type: TransactionType.withdrawal,
      balanceAfter: newBalance,
    );

    await _txBox.put(transaction.id, transaction.toMap());
    await saveBalance(newBalance);

    return transaction;
  }

  /// Update a transaction
  Future<TransactionModel?> updateTransaction({
    required String id,
    double? amount,
    String? description,
  }) async {
    final existingMap = _txBox.get(id);
    if (existingMap == null) return null;

    final existing = TransactionModel.fromMap(existingMap);
    final amountDiff = (amount ?? existing.amount) - existing.amount;

    // Recalculate balance if amount changed
    if (amountDiff != 0) {
      final currentBalance = getBalance();
      if (existing.isCredit) {
        await saveBalance(currentBalance + amountDiff);
      } else {
        await saveBalance(currentBalance - amountDiff);
      }
    }

    final updated = TransactionModel(
      id: existing.id,
      amount: amount ?? existing.amount,
      description: description ?? existing.description,
      date: existing.date,
      type: existing.type,
      balanceAfter: existing.balanceAfter + amountDiff,
      category: existing.category,
    );

    await _txBox.put(id, updated.toMap());
    return updated;
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(String id) async {
    final existingMap = _txBox.get(id);
    if (existingMap == null) return false;

    final existing = TransactionModel.fromMap(existingMap);

    // Reverse the balance change
    final currentBalance = getBalance();
    if (existing.isCredit) {
      await saveBalance(currentBalance - existing.amount);
    } else {
      await saveBalance(currentBalance + existing.amount);
    }

    await _txBox.delete(id);
    return true;
  }

  /// Clear all data (for testing)
  Future<void> clearAll() async {
    await _txBox.clear();
    await _balanceBoxRef.clear();
  }
}
