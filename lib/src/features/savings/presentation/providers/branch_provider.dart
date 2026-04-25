import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/branch_datasource.dart';
import '../../domain/entities/branch_info.dart';

final _branchDatasource = BranchDatasource();

/// GET /branches → BranchInfo (cabang pertama / utama)
///
/// Tidak menggunakan autoDispose agar data cached selama sesi berlangsung.
final branchProvider = FutureProvider<BranchInfo>((ref) async {
  return _branchDatasource.getFirstBranch();
});
