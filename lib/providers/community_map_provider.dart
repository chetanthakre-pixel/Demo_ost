import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../repositories/report_repository.dart';

final communityMapProvider = FutureProvider.autoDispose<List<Report>>((ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getAllReports();
});
