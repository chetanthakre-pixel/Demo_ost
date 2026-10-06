// lib/models/history_item.dart
import 'enums.dart';

class HistoryItem {
  final String logId;
  final ReportStatus oldStatus;
  final ReportStatus newStatus;
  final String? changedByName;
  final Role changedByRole;
  final String? comment;
  final DateTime timestamp;

  HistoryItem({
    required this.logId,
    required this.oldStatus,
    required this.newStatus,
    this.changedByName,
    required this.changedByRole,
    this.comment,
    required this.timestamp,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      logId: json['log_id'] as String,
      oldStatus: ReportStatus.fromJson(json['old_status'] as String),
      newStatus: ReportStatus.fromJson(json['new_status'] as String),
      changedByName: json['changed_by_name'] as String?,
      changedByRole: Role.fromJson(json['changed_by_role'] as String),
      comment: json['comment'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }
}
