// lib/models/report_detail.dart
import 'report.dart';

class ReportDetail {
  final Report report;
  final AiResult? aiResult;
  final Road? road;
  final Sla? sla;
  final Resolution? resolution;

  ReportDetail({
    required this.report,
    this.aiResult,
    this.road,
    this.sla,
    this.resolution,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      report: Report.fromJson(json),
      aiResult: json['ai_result'] != null
          ? AiResult.fromJson(json['ai_result'] as Map<String, dynamic>)
          : null,
      road: json['road'] != null
          ? Road.fromJson(json['road'] as Map<String, dynamic>)
          : null,
      sla: json['sla'] != null
          ? Sla.fromJson(json['sla'] as Map<String, dynamic>)
          : null,
      resolution: json['resolution'] != null
          ? Resolution.fromJson(json['resolution'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AiResult {
  final String modelName;
  final String modelVersion;
  final int detectedClassId;
  final String detectedClass;
  final String category;
  final double confidence;
  final DateTime processedAt;

  AiResult({
    required this.modelName,
    required this.modelVersion,
    required this.detectedClassId,
    required this.detectedClass,
    required this.category,
    required this.confidence,
    required this.processedAt,
  });

  factory AiResult.fromJson(Map<String, dynamic> json) {
    return AiResult(
      modelName: json['model_name'] as String,
      modelVersion: json['model_version'] as String,
      detectedClassId: json['detected_class_id'] as int,
      detectedClass: json['detected_class'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      processedAt: DateTime.parse(json['processed_at'] as String).toLocal(),
    );
  }
}

class Road {
  final String roadId;
  final String roadName;
  final String? roadSegment;
  final String? dlpStartDate;
  final String? dlpEndDate;
  final bool? dlpActive;

  Road({
    required this.roadId,
    required this.roadName,
    this.roadSegment,
    this.dlpStartDate,
    this.dlpEndDate,
    this.dlpActive,
  });

  factory Road.fromJson(Map<String, dynamic> json) {
    return Road(
      roadId: json['road_id'] as String,
      roadName: json['road_name'] as String,
      roadSegment: json['road_segment'] as String?,
      dlpStartDate: json['dlp_start_date'] as String?,
      dlpEndDate: json['dlp_end_date'] as String?,
      dlpActive: json['dlp_active'] as bool?,
    );
  }
}

class Sla {
  final DateTime dueAt;
  final bool breached;

  Sla({
    required this.dueAt,
    required this.breached,
  });

  factory Sla.fromJson(Map<String, dynamic> json) {
    return Sla(
      dueAt: DateTime.parse(json['due_at'] as String).toLocal(),
      breached: json['breached'] as bool? ?? false,
    );
  }
}

class Resolution {
  final String? note;
  final DateTime? resolvedAt;

  Resolution({
    this.note,
    this.resolvedAt,
  });

  factory Resolution.fromJson(Map<String, dynamic> json) {
    return Resolution(
      note: json['note'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String).toLocal()
          : null,
    );
  }
}
