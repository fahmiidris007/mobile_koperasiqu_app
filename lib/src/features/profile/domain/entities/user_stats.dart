import 'package:equatable/equatable.dart';

/// Stats from GET /user/stats
class UserStats extends Equatable {
  const UserStats({
    required this.totalTransactions,
    required this.totalSpent,
    required this.totalSpentFormatted,
    required this.transactionsThisMonth,
    required this.spentThisMonth,
    required this.spentThisMonthFormatted,
    required this.averagePerTransactionFormatted,
    required this.memberSince,
    required this.memberDays,
  });

  final int totalTransactions;
  final double totalSpent;
  final String totalSpentFormatted;
  final int transactionsThisMonth;
  final double spentThisMonth;
  final String spentThisMonthFormatted;
  final String averagePerTransactionFormatted;
  final DateTime memberSince;
  final double memberDays;

  int get memberDaysInt => memberDays.ceil();

  @override
  List<Object?> get props => [totalTransactions, totalSpent, memberSince];
}
