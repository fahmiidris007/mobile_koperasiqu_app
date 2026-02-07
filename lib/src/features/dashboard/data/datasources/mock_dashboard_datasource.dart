import '../../domain/entities/dashboard_data.dart';

/// Mock data source for dashboard
class MockDashboardDatasource {
  MockDashboardDatasource();

  /// Get dashboard data for current user
  Future<DashboardData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return DashboardData(
      totalSavings: 15750000,
      savingsGrowth: 2.5,
      loyaltyPoints: 1250,
      memberSince: DateTime(2024, 1, 15),
      memberTier: MemberTier.silver,
      recentTransactions: _mockTransactions,
      quickActions: _mockQuickActions,
      notifications: _mockNotifications,
    );
  }

  static final List<RecentTransaction> _mockTransactions = [
    RecentTransaction(
      id: 'tx-001',
      title: 'Setoran Bulanan',
      subtitle: 'Tabungan Utama',
      amount: 500000,
      type: TransactionType.deposit,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      icon: 'savings',
    ),
    RecentTransaction(
      id: 'tx-002',
      title: 'Pembelian Pulsa',
      subtitle: 'Telkomsel 08123***789',
      amount: 50000,
      type: TransactionType.purchase,
      date: DateTime.now().subtract(const Duration(days: 1)),
      icon: 'phone',
    ),
    RecentTransaction(
      id: 'tx-003',
      title: 'Cashback Belanja',
      subtitle: 'Promo Akhir Tahun',
      amount: 25000,
      type: TransactionType.cashback,
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: 'cashback',
    ),
    RecentTransaction(
      id: 'tx-004',
      title: 'Belanja Produk',
      subtitle: 'Koperasi Mart',
      amount: 175000,
      type: TransactionType.purchase,
      date: DateTime.now().subtract(const Duration(days: 3)),
      icon: 'shopping',
    ),
    RecentTransaction(
      id: 'tx-005',
      title: 'Penarikan',
      subtitle: 'Transfer ke Bank BCA',
      amount: 1000000,
      type: TransactionType.withdrawal,
      date: DateTime.now().subtract(const Duration(days: 5)),
      icon: 'withdraw',
    ),
  ];

  static final List<QuickAction> _mockQuickActions = [
    const QuickAction(
      id: 'qa-1',
      label: 'Tabungan',
      icon: 'savings',
      route: '/savings',
    ),
    const QuickAction(
      id: 'qa-2',
      label: 'Setor',
      icon: 'deposit',
      route: '/savings/deposit',
    ),
    const QuickAction(
      id: 'qa-3',
      label: 'Belanja',
      icon: 'shopping',
      route: '/shopping',
      badge: 'New',
    ),
    const QuickAction(id: 'qa-4', label: 'PPOB', icon: 'ppob', route: '/ppob'),
    const QuickAction(
      id: 'qa-5',
      label: 'Transfer',
      icon: 'transfer',
      route: '/transfer',
    ),
    const QuickAction(
      id: 'qa-6',
      label: 'Riwayat',
      icon: 'history',
      route: '/history',
    ),
  ];

  static final List<DashboardNotification> _mockNotifications = [
    DashboardNotification(
      id: 'notif-1',
      title: 'Promo Akhir Tahun!',
      message:
          'Dapatkan cashback 5% untuk setiap pembelanjaan di Koperasi Mart',
      type: NotificationType.promo,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    DashboardNotification(
      id: 'notif-2',
      title: 'RAT 2024',
      message: 'Rapat Anggota Tahunan akan dilaksanakan pada 15 Januari 2025',
      type: NotificationType.info,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];
}
