import 'package:equatable/equatable.dart';

/// Data cabang koperasi dari GET /branches
class BranchInfo extends Equatable {
  const BranchInfo({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    this.about,
  });

  final int id;
  final String name;
  final String phoneNumber;
  final String email;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final String? about;

  /// Nomor WA yang dipakai untuk buka WhatsApp (tanpa +/spasi)
  String get whatsappNumber => phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        bankName,
        bankAccountNumber,
        bankAccountName,
        about,
      ];
}
