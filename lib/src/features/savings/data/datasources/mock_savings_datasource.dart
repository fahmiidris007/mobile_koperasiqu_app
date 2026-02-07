import '../../domain/entities/savings_account.dart';

/// Mock data source for savings
class MockSavingsDatasource {
  MockSavingsDatasource();

  /// Get primary savings account
  Future<SavingsAccount> getPrimarySavings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPrimaryAccount;
  }

  /// Get all savings accounts
  Future<List<SavingsAccount>> getAllSavings() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [_mockPrimaryAccount, _mockEducationAccount];
  }

  /// Get savings transactions
  Future<List<SavingsTransaction>> getTransactions(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockTransactions;
  }

  /// Get monthly summary for charts
  Future<List<MonthlySummary>> getMonthlySummary(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMonthlySummary;
  }

  /// Simulate deposit
  Future<bool> deposit({
    required String accountId,
    required double amount,
    required String description,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // In real app, this would call API
    return true;
  }

  /// Simulate withdrawal
  Future<bool> withdraw({
    required String accountId,
    required double amount,
    required String description,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // Mock data
  static final _mockPrimaryAccount = SavingsAccount(
    id: 'sav-001',
    name: 'Tabungan Utama',
    accountNumber: '1234567890',
    balance: 15750000,
    type: SavingsType.regular,
    interestRate: 3.5,
    openedDate: DateTime(2024, 1, 15),
    transactions: _mockTransactions,
  );

  static final _mockEducationAccount = SavingsAccount(
    id: 'sav-002',
    name: 'Tabungan Pendidikan',
    accountNumber: '1234567891',
    balance: 5000000,
    type: SavingsType.education,
    interestRate: 4.0,
    openedDate: DateTime(2024, 3, 1),
  );

  static final List<SavingsTransaction> _mockTransactions = [
    SavingsTransaction(
      id: 'st-001',
      type: SavingsTransactionType.deposit,
      amount: 500000,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Setoran Bulanan',
      runningBalance: 15750000,
    ),
    SavingsTransaction(
      id: 'st-002',
      type: SavingsTransactionType.interest,
      amount: 45000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Bunga Desember 2024',
      runningBalance: 15250000,
    ),
    SavingsTransaction(
      id: 'st-003',
      type: SavingsTransactionType.deposit,
      amount: 1000000,
      date: DateTime.now().subtract(const Duration(days: 7)),
      description: 'Setoran THR',
      runningBalance: 15205000,
    ),
    SavingsTransaction(
      id: 'st-004',
      type: SavingsTransactionType.withdrawal,
      amount: 500000,
      date: DateTime.now().subtract(const Duration(days: 14)),
      description: 'Penarikan Tunai',
      runningBalance: 14205000,
    ),
    SavingsTransaction(
      id: 'st-005',
      type: SavingsTransactionType.deposit,
      amount: 500000,
      date: DateTime.now().subtract(const Duration(days: 32)),
      description: 'Setoran November',
      runningBalance: 14705000,
    ),
    SavingsTransaction(
      id: 'st-006',
      type: SavingsTransactionType.cashback,
      amount: 25000,
      date: DateTime.now().subtract(const Duration(days: 35)),
      description: 'Cashback Belanja Koperasi',
      runningBalance: 14205000,
    ),
  ];

  static final List<MonthlySummary> _mockMonthlySummary = [
    const MonthlySummary(
      month: 7,
      year: 2024,
      totalDeposit: 2000000,
      totalWithdrawal: 500000,
      endBalance: 10500000,
    ),
    const MonthlySummary(
      month: 8,
      year: 2024,
      totalDeposit: 1500000,
      totalWithdrawal: 200000,
      endBalance: 11800000,
    ),
    const MonthlySummary(
      month: 9,
      year: 2024,
      totalDeposit: 1000000,
      totalWithdrawal: 300000,
      endBalance: 12500000,
    ),
    const MonthlySummary(
      month: 10,
      year: 2024,
      totalDeposit: 1500000,
      totalWithdrawal: 1000000,
      endBalance: 13000000,
    ),
    const MonthlySummary(
      month: 11,
      year: 2024,
      totalDeposit: 1200000,
      totalWithdrawal: 400000,
      endBalance: 13800000,
    ),
    const MonthlySummary(
      month: 12,
      year: 2024,
      totalDeposit: 2500000,
      totalWithdrawal: 500000,
      endBalance: 15750000,
    ),
  ];
}
