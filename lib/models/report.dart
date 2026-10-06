// lib/models/report.dart
import 'enums.dart';

class Report {
  final String reportId;
  final String? ownerId;
  final Source source;
  final Category category;
  final String? description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String? address;
  final int severity;
  final double priorityScore;
  final ReportStatus status;
  final String? departmentId;
  final String? departmentName;
  final double? aiConfidence;
  final bool isDuplicate;
  final String? duplicateOf;
  final int reportCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.reportId,
    this.ownerId,
    required this.source,
    required this.category,
    this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.severity,
    required this.priorityScore,
    required this.status,
    this.departmentId,
    this.departmentName,
    this.aiConfidence,
    required this.isDuplicate,
    this.duplicateOf,
    required this.reportCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['report_id'] as String,
      ownerId: json['owner_id'] as String?,
      source: Source.fromJson(json['source'] as String),
      category: Category.fromJson(json['category'] as String),
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      severity: json['severity'] as int,
      priorityScore: (json['priority_score'] as num).toDouble(),
      status: ReportStatus.fromJson(json['status'] as String),
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
      isDuplicate: json['is_duplicate'] as bool? ?? false,
      duplicateOf: json['duplicate_of'] as String?,
      reportCount: json['report_count'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'owner_id': ownerId,
      'source': source.value,
      'category': category.value,
      'description': description,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'severity': severity,
      'priority_score': priorityScore,
      'status': status.value,
      'department_id': departmentId,
      'department_name': departmentName,
      'ai_confidence': aiConfidence,
      'is_duplicate': isDuplicate,
      'duplicate_of': duplicateOf,
      'report_count': reportCount,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}

class ReportListResponse {
  final List<Report> reports;
  final int total;

  ReportListResponse({required this.reports, required this.total});
}
