import 'package:equatable/equatable.dart';

/// Dashboard summary entity containing user's financial overview
class DashboardData extends Equatable {
  const DashboardData({
    required this.totalSavings,
    required this.savingsGrowth,
    required this.loyaltyPoints,
    required this.memberSince,
    required this.memberTier,
    required this.recentTransactions,
    required this.quickActions,
    this.notifications = const [],
  });

  final double totalSavings;
  final double savingsGrowth; // Percentage (e.g., 2.5 = +2.5%)
  final int loyaltyPoints;
  final DateTime memberSince;
  final MemberTier memberTier;
  final List<RecentTransaction> recentTransactions;
  final List<QuickAction> quickActions;
  final List<DashboardNotification> notifications;

  @override
  List<Object?> get props => [
    totalSavings,
    savingsGrowth,
    loyaltyPoints,
    memberSince,
    memberTier,
    recentTransactions,
    quickActions,
    notifications,
  ];
}

/// Member tier/level
enum MemberTier {
  bronze,
  silver,
  gold,
  platinum;

  String get displayName {
    switch (this) {
      case MemberTier.bronze:
        return 'Bronze';
      case MemberTier.silver:
        return 'Silver';
      case MemberTier.gold:
        return 'Gold';
      case MemberTier.platinum:
        return 'Platinum';
    }
  }

  double get minSavings {
    switch (this) {
      case MemberTier.bronze:
        return 0;
      case MemberTier.silver:
        return 5000000;
      case MemberTier.gold:
        return 25000000;
      case MemberTier.platinum:
        return 100000000;
    }
  }
}

/// Recent transaction for dashboard list
class RecentTransaction extends Equatable {
  const RecentTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String icon; // Icon name or asset path

  bool get isCredit =>
      type == TransactionType.deposit || type == TransactionType.cashback;
  bool get isDebit =>
      type == TransactionType.withdrawal || type == TransactionType.purchase;

  @override
  List<Object?> get props => [id, title, subtitle, amount, type, date, icon];
}

enum TransactionType {
  deposit,
  withdrawal,
  purchase,
  cashback,
  transfer;

  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Setoran';
      case TransactionType.withdrawal:
        return 'Penarikan';
      case TransactionType.purchase:
        return 'Pembelian';
      case TransactionType.cashback:
        return 'Cashback';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}

/// Quick action button data
class QuickAction extends Equatable {
  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.badge,
  });

  final String id;
  final String label;
  final String icon;
  final String route;
  final String? badge;

  @override
  List<Object?> get props => [id, label, icon, route, badge];
}

/// Dashboard notification
class DashboardNotification extends Equatable {
  const DashboardNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  @override
  List<Object?> get props => [id, title, message, type, timestamp, isRead];
}

enum NotificationType { promo, info, warning, success }
