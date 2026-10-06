import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

final reportListProvider = FutureProvider<ReportListResponse>((ref) async {
  final repository = ref.read(reportRepositoryProvider);
  return repository.getReports();
});
