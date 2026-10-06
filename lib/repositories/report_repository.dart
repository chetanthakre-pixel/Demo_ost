import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:path/path.dart' as path;
import '../models/report.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

class ReportRepository {
  final _supabase = supa.Supabase.instance.client;

  String _generateId() => 'r_' + Random().nextInt(9999999).toString();

  Future<ReportListResponse> getReports({int page = 1, int pageSize = 20}) async {
    final start = (page - 1) * pageSize;
    final end = start + pageSize - 1;
    
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('reports')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false)
        .range(start, end)
        .count(supa.CountOption.exact);

    final reports = (response.data as List).map((json) => Report.fromJson(json)).toList();
    final total = response.count;
    
    return ReportListResponse(reports: reports, total: total);
  }

  Future<List<Report>> getAllReports() async {
    // Fetches all reports (or a large batch) to display on the community map
    final response = await _supabase
        .from('reports')
        .select()
        .order('created_at', ascending: false)
        .limit(200); // Limit to 200 most recent for performance

    return (response as List).map((json) => Report.fromJson(json)).toList();
  }

  Future<Report> createReport({
    required String category,
    required double latitude,
    required double longitude,
    required String imagePath,
    String? description,
    String? address,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final reportId = _generateId();
    final ext = path.extension(imagePath);
    final fileName = '$reportId$ext';
    
    final file = File(imagePath);
    await _supabase.storage.from('report-images').upload(
      fileName,
      file,
      fileOptions: const supa.FileOptions(cacheControl: '3600', upsert: false),
    );

    final imageUrl = _supabase.storage.from('report-images').getPublicUrl(fileName);

    final data = await _supabase.from('reports').insert({
      'report_id': reportId,
      'owner_id': userId,
      'source': 'citizen',
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'geom': 'SRID=4326;POINT($longitude $latitude)',
      'address': address,
      'severity': 3,
      'priority_score': 50.0,
      'status': 'submitted'
    }).select().single();

    return Report.fromJson(data);
  }

  Future<void> deleteReport(String reportId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    // First fetch the report to get the image URL so we can delete the image
    final reportData = await _supabase
        .from('reports')
        .select('image_url')
        .eq('report_id', reportId)
        .eq('owner_id', userId)
        .single();
    
    final String? imageUrl = reportData['image_url'];
    if (imageUrl != null) {
      try {
        final uri = Uri.parse(imageUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length > 2) {
          final fileName = pathSegments.last;
          await _supabase.storage.from('report-images').remove([fileName]);
        }
      } catch (e) {
        print('Failed to delete image from storage: $e');
      }
    }

    await _supabase
        .from('reports')
        .delete()
        .eq('report_id', reportId)
        .eq('owner_id', userId);
  }
}

