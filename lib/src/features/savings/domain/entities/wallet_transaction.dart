import 'package:equatable/equatable.dart';

/// Single wallet transaction from GET /wallet/transactions
class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.amountFormatted,
    required this.totalAmount,
    required this.totalAmountFormatted,
    required this.serviceFee,
    required this.serviceFeeFormatted,
    this.uniqueCode,
    this.description,
    this.proofOfPaymentUrl,
    required this.createdAt,
  });

  final int id;

  /// e.g. 'topup', 'payment', 'transfer'
  final String type;

  /// e.g. 'pending', 'approved', 'rejected'
  final String status;

  final double amount;
  final String amountFormatted;
  final double totalAmount;
  final String totalAmountFormatted;
  final double serviceFee;
  final String serviceFeeFormatted;
  final int? uniqueCode;
  final String? description;
  final String? proofOfPaymentUrl;
  final DateTime createdAt;

  /// Credit jika topup yang approved, debit jika payment/purchase
  bool get isCredit => type == 'topup' && status == 'approved';
  bool get isPending => status == 'pending';

  String get typeLabel {
    switch (type) {
      case 'topup':
        return 'Top Up';
      case 'payment':
        return 'Pembayaran';
      case 'transfer':
        return 'Transfer';
      default:
        return type;
    }
  }

  @override
  List<Object?> get props => [id, type, status, amount, createdAt];
}

/// Result of POST /wallet/topup
class TopupResult extends Equatable {
  const TopupResult({
    required this.id,
    required this.status,
    required this.amount,
    required this.amountFormatted,
    required this.totalAmount,
    required this.totalAmountFormatted,
    required this.serviceFee,
    required this.serviceFeeFormatted,
    this.uniqueCode,
    this.referenceCode,
    required this.createdAt,
  });

  final int id;
  final String status;
  final double amount;
  final String amountFormatted;
  final double totalAmount;
  final String totalAmountFormatted;
  final double serviceFee;
  final String serviceFeeFormatted;
  final int? uniqueCode;
  final String? referenceCode;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, status, amount, totalAmount, uniqueCode, referenceCode];
}
