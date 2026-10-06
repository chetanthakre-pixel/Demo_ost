import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStats {
  final int totalReports;
  final int resolvedReports;
  final int points;
  final String rank;

  const UserStats({
    required this.totalReports,
    required this.resolvedReports,
    required this.points,
    required this.rank,
  });
}

final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) throw Exception('Not authenticated');

  // We fetch counts using exactly matched queries
  final totalResp = await supabase
      .from('reports')
      .select('report_id')
      .eq('owner_id', userId)
      .count(CountOption.exact);

  final resolvedResp = await supabase
      .from('reports')
      .select('report_id')
      .eq('owner_id', userId)
      .eq('status', 'resolved')
      .count(CountOption.exact);

  final total = totalResp.count ?? 0;
  final resolved = resolvedResp.count ?? 0;
  final submitted = total - resolved;

  // Gamification Logic
  // 50 points for resolved, 10 for submitted
  final points = (resolved * 50) + (submitted * 10);
  
  String rank;
  if (points >= 500) rank = 'GOLD CITIZEN';
  else if (points >= 200) rank = 'SILVER CITIZEN';
  else if (points >= 50) rank = 'BRONZE CITIZEN';
  else rank = 'NEW CITIZEN';

  return UserStats(
    totalReports: total,
    resolvedReports: resolved,
    points: points,
    rank: rank,
  );
});
