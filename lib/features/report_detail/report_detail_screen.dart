import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/report_detail_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/section_label.dart';
import '../../core/widgets/hairline_divider.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/dark_osm_map.dart';

import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/community_map_provider.dart';
import '../../providers/user_stats_provider.dart';
import '../../repositories/report_repository.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_scaffold.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  Future<void> _deleteReport(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface2,
        title: const Text('Delete Report', style: TextStyle(color: AppTheme.text, fontFamily: 'Inter')),
        content: const Text('Are you sure you want to delete this report? This cannot be undone.', style: TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: AppTheme.text)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('DELETE', style: TextStyle(color: AppTheme.statusRejected)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(reportRepositoryProvider).deleteReport(reportId);
        ref.invalidate(reportListProvider);
        ref.invalidate(communityMapProvider);
        ref.invalidate(userStatsProvider);
        if (context.mounted) {
          context.pop(); // Go back
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppTheme.statusRejected));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsyncValue = ref.watch(reportDetailProvider(reportId));
    final currentUser = ref.watch(authProvider).value;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('REPORT DETAIL'),
        actions: [
          reportAsyncValue.whenOrNull(
            data: (detail) {
              if (currentUser != null && detail.report.ownerId == currentUser.userId) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.statusRejected),
                  onPressed: () => _deleteReport(context, ref),
                  tooltip: 'Delete Report',
                );
              }
              return const SizedBox();
            },
          ) ?? const SizedBox(),
        ],
      ),
      body: reportAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err', style: const TextStyle(color: AppTheme.statusRejected)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(reportDetailProvider(reportId)),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
        data: (detail) {
          final report = detail.report;
          final dateFormatted = DateFormat('MMM d, yyyy • HH:mm').format(report.createdAt);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Header
                Image.network(
                  report.imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    color: AppTheme.surface2,
                    child: const Icon(Icons.broken_image, size: 64, color: AppTheme.textMuted),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StatusChip(status: report.status.value),
                          Text(dateFormatted, style: AppTheme.labelStyle),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Category Title
                      Text(
                        report.category.label.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      
                      if (report.description != null && report.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(report.description!, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                      const SizedBox(height: 32),

                      // Location & Assignment
                      const HairlineDivider(withChecker: true),
                      const SizedBox(height: 24),
                      
                      const SectionLabel('LOCATION'),
                      const SizedBox(height: 8),
                      Text('${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)}', style: const TextStyle(fontFamily: 'Inter', fontSize: 16)),
                      if (report.address != null) ...[
                        const SizedBox(height: 4),
                        Text(report.address!, style: const TextStyle(color: AppTheme.textMuted)),
                      ],
                      const SizedBox(height: 16),
                      DarkOsmMap(latitude: report.latitude, longitude: report.longitude),
                      const SizedBox(height: 24),
                      
                      const SectionLabel('ASSIGNED TO'),
                      const SizedBox(height: 8),
                      Text(report.departmentName ?? 'Pending Assignment', style: const TextStyle(fontFamily: 'Inter', fontSize: 16)),
                      const SizedBox(height: 32),

                      // Timeline
                      const HairlineDivider(withChecker: true),
                      const SizedBox(height: 24),
                      const SectionLabel('TIMELINE'),
                      const SizedBox(height: 16),
                      _buildTimeline(report.status.value, report.createdAt, detail.resolution?.resolvedAt),
                      const SizedBox(height: 32),

                      // AI Details
                      if (detail.aiResult != null) ...[
                        const HairlineDivider(withChecker: true),
                        const SizedBox(height: 24),
                        const SectionLabel('AI DETECTION'),
                        const SizedBox(height: 8),
                        Text('Class: ${detail.aiResult!.detectedClass}', style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Confidence: ${(detail.aiResult!.confidence * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 32),
                      ],

                      // Resolution Note
                      if (detail.resolution?.note != null) ...[
                        const HairlineDivider(withChecker: true),
                        const SizedBox(height: 24),
                        const SectionLabel('RESOLUTION NOTE'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface2,
                            border: Border.all(color: AppTheme.hairline),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(detail.resolution!.note!, style: const TextStyle(color: AppTheme.text)),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline(String currentStatus, DateTime createdAt, DateTime? resolvedAt) {
    // A simplified placeholder timeline since we don't have the history endpoint fetched
    final statuses = ['submitted', 'verified', 'assigned', 'in_progress', 'resolved'];
    int currentIndex = statuses.indexOf(currentStatus);
    
    // If status is rejected or escalated, we show a special timeline
    if (currentStatus == 'rejected' || currentStatus == 'escalated') {
      return Column(
        children: [
          _buildTimelineNode('submitted', true, isFirst: true),
          _buildTimelineNode(currentStatus, true, isLast: true),
        ],
      );
    }

    if (currentIndex == -1) currentIndex = 0;

    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = index <= currentIndex;
        
        return _buildTimelineNode(
          status,
          isCompleted,
          isFirst: index == 0,
          isLast: index == statuses.length - 1,
        );
      }),
    );
  }

  Widget _buildTimelineNode(String status, bool isCompleted, {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The vertical line
                Positioned(
                  top: isFirst ? 16 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 16 : null,
                  width: 1,
                  child: Container(color: AppTheme.hairline),
                ),
                // The square node
                Positioned(
                  top: 12,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppTheme.getStatusColor(status) : AppTheme.surface,
                      border: Border.all(color: isCompleted ? Colors.transparent : AppTheme.hairline, width: 1),
                      shape: BoxShape.rectangle, // Square nodes
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
              child: Text(
                status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? AppTheme.text : AppTheme.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
