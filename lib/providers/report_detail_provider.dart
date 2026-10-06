import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/report_detail.dart';

final reportDetailProvider = FutureProvider.family<ReportDetail, String>((ref, reportId) async {
  final supabase = supa.Supabase.instance.client;
  final response = await supabase
      .from('reports')
      .select()
      .eq('report_id', reportId)
      .single();
  
  return ReportDetail.fromJson(response);
});
