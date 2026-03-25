import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/datasources/mock_auth_datasource.dart'; // re-use AuthException
import '../../domain/entities/wallet_info.dart';
import '../../domain/entities/wallet_transaction.dart';

/// Real API datasource for wallet operations
class WalletDatasource {
  Dio get _dio => ApiClient.instance;

  // ── GET /wallet ────────────────────────────────────────────────────────────

  Future<WalletInfo> getWallet() async {
    try {
      final response = await _dio.get(ApiEndpoints.wallet);
      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return _walletFromJson(data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── GET /wallet/transactions ───────────────────────────────────────────────

  Future<List<WalletTransaction>> getWalletTransactions() async {
    try {
      final response = await _dio.get(ApiEndpoints.walletTransactions);
      final data = response.data as Map<String, dynamic>;
      final txList =
          (data['data'] as Map<String, dynamic>)['transactions'] as List;
      return txList
          .map((e) => _txFromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── POST /wallet/topup ─────────────────────────────────────────────────────

  Future<TopupResult> topup({
    required double amount,
    required int uniqueCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.walletTopup,
        data: {'amount': amount.toInt(), 'unique_code': uniqueCode},
        options: Options(contentType: 'application/json'),
      );
      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return _topupFromJson(data);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ── JSON helpers ──────────────────────────────────────────────────────────

  WalletInfo _walletFromJson(Map<String, dynamic> j) {
    return WalletInfo(
      id: (j['id'] as num).toInt(),
      balance: (j['balance'] as num).toDouble(),
      balanceFormatted: j['balance_formatted']?.toString() ?? 'Rp 0',
      createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  WalletTransaction _txFromJson(Map<String, dynamic> j) {
    return WalletTransaction(
      id: (j['id'] as num).toInt(),
      type: j['type']?.toString() ?? 'topup',
      status: j['status']?.toString() ?? 'pending',
      amount: (j['amount'] as num).toDouble(),
      amountFormatted: j['amount_formatted']?.toString() ?? '',
      totalAmount: (j['total_amount'] as num? ?? j['amount'] as num).toDouble(),
      totalAmountFormatted:
          j['total_amount_formatted']?.toString() ?? j['amount_formatted']?.toString() ?? '',
      serviceFee: (j['service_fee'] as num? ?? 0).toDouble(),
      serviceFeeFormatted: j['service_fee_formatted']?.toString() ?? 'Rp 0',
      uniqueCode: j['unique_code'] != null
          ? (j['unique_code'] as num).toInt()
          : null,
      description: j['description']?.toString(),
      proofOfPaymentUrl: j['proof_of_payment_url']?.toString(),
      createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  TopupResult _topupFromJson(Map<String, dynamic> j) {
    return TopupResult(
      id: (j['id'] as num).toInt(),
      status: j['status']?.toString() ?? 'pending',
      amount: (j['amount'] as num).toDouble(),
      amountFormatted: j['amount_formatted']?.toString() ?? '',
      totalAmount: (j['total_amount'] as num).toDouble(),
      totalAmountFormatted: j['total_amount_formatted']?.toString() ?? '',
      serviceFee: (j['service_fee'] as num? ?? 0).toDouble(),
      serviceFeeFormatted: j['service_fee_formatted']?.toString() ?? 'Rp 0',
      uniqueCode: (j['unique_code'] as num).toInt(),
      createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String _parseError(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map) {
        if (body['errors'] != null) {
          final errors = body['errors'] as Map;
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        if (body['message'] != null) return body['message'].toString();
      }
      return 'Error ${response.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    return 'Tidak dapat terhubung ke server.';
  }
}
