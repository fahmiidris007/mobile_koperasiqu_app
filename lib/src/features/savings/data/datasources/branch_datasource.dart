import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/data/datasources/mock_auth_datasource.dart' show AuthException;
import '../../domain/entities/branch_info.dart';

/// Datasource untuk GET /branches — info cabang koperasi (phone, rekening bank)
class BranchDatasource {
  Dio get _dio => ApiClient.instance;

  Future<BranchInfo> getFirstBranch() async {
    try {
      final response = await _dio.get(ApiEndpoints.branches);
      final body = response.data as Map<String, dynamic>;
      final branches =
          (body['data'] as Map<String, dynamic>)['branches'] as List<dynamic>;
      if (branches.isEmpty) {
        throw AuthException('Data cabang tidak tersedia.');
      }
      return _branchFromJson(branches.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  BranchInfo _branchFromJson(Map<String, dynamic> j) {
    return BranchInfo(
      id: (j['id'] as num).toInt(),
      name: j['name']?.toString() ?? '',
      phoneNumber: j['phone_number']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      bankName: j['bank_name']?.toString() ?? '',
      bankAccountNumber: j['bank_account_number']?.toString() ?? '',
      bankAccountName: j['bank_account_name']?.toString() ?? '',
      about: j['about']?.toString(),
      address: j['address']?.toString(),
      latitude: j['latitude'] != null
          ? double.tryParse(j['latitude'].toString())
          : null,
      longitude: j['longitude'] != null
          ? double.tryParse(j['longitude'].toString())
          : null,
    );
  }

  String _parseError(DioException e) {
    final response = e.response;
    if (response != null) {
      final body = response.data;
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
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
