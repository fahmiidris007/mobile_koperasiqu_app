import 'package:equatable/equatable.dart';

/// Savings account entity
class SavingsAccount extends Equatable {
  const SavingsAccount({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.balance,
    required this.type,
    required this.interestRate,
    this.openedDate,
    this.transactions = const [],
  });

  final String id;
  final String name;
  final String accountNumber;
  final double balance;
  final SavingsType type;
  final double interestRate; // Annual percentage
  final DateTime? openedDate;
  final List<SavingsTransaction> transactions;

  @override
  List<Object?> get props => [
    id,
    name,
    accountNumber,
    balance,
    type,
    interestRate,
    openedDate,
    transactions,
  ];
}

enum SavingsType {
  regular,
  education,
  hajj,
  holiday,
  custom;

  String get displayName {
    switch (this) {
      case SavingsType.regular:
        return 'Tabungan Utama';
      case SavingsType.education:
        return 'Tabungan Pendidikan';
      case SavingsType.hajj:
        return 'Tabungan Haji';
      case SavingsType.holiday:
        return 'Tabungan Liburan';
      case SavingsType.custom:
        return 'Tabungan Lainnya';
    }
  }

  String get icon {
    switch (this) {
      case SavingsType.regular:
        return 'savings';
      case SavingsType.education:
        return 'school';
      case SavingsType.hajj:
        return 'mosque';
      case SavingsType.holiday:
        return 'beach';
      case SavingsType.custom:
        return 'piggy_bank';
    }
  }
}

/// Individual savings transaction
class SavingsTransaction extends Equatable {
  const SavingsTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.reference,
    this.runningBalance,
  });

  final String id;
  final SavingsTransactionType type;
  final double amount;
  final DateTime date;
  final String description;
  final String? reference;
  final double? runningBalance;

  bool get isCredit =>
      type == SavingsTransactionType.deposit ||
      type == SavingsTransactionType.interest ||
      type == SavingsTransactionType.cashback;

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    date,
    description,
    reference,
    runningBalance,
  ];
}

enum SavingsTransactionType {
  deposit,
  withdrawal,
  transfer,
  interest,
  cashback,
  fee;

  String get displayName {
    switch (this) {
      case SavingsTransactionType.deposit:
        return 'Setoran';
      case SavingsTransactionType.withdrawal:
        return 'Penarikan';
      case SavingsTransactionType.transfer:
        return 'Transfer';
      case SavingsTransactionType.interest:
        return 'Bunga';
      case SavingsTransactionType.cashback:
        return 'Cashback';
      case SavingsTransactionType.fee:
        return 'Biaya Admin';
    }
  }
}

/// Monthly summary for chart display
class MonthlySummary extends Equatable {
  const MonthlySummary({
    required this.month,
    required this.year,
    required this.totalDeposit,
    required this.totalWithdrawal,
    required this.endBalance,
  });

  final int month;
  final int year;
  final double totalDeposit;
  final double totalWithdrawal;
  final double endBalance;

  @override
  List<Object?> get props => [
    month,
    year,
    totalDeposit,
    totalWithdrawal,
    endBalance,
  ];
}
