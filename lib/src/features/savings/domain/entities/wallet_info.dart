import 'package:equatable/equatable.dart';

/// Wallet info entity — maps from GET /wallet
class WalletInfo extends Equatable {
  const WalletInfo({
    required this.id,
    required this.balance,
    required this.balanceFormatted,
    required this.createdAt,
  });

  final int id;
  final double balance;
  final String balanceFormatted;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, balance, balanceFormatted, createdAt];
}
