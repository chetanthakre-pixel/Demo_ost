// lib/models/enums.dart

enum Role {
  citizen('citizen'),
  officer('officer'),
  admin('admin'),
  contractor('contractor'),
  unknown('unknown');

  final String value;
  const Role(this.value);

  factory Role.fromJson(String json) {
    return Role.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Role.unknown,
    );
  }
}

enum Source {
  citizen('citizen'),
  vehicleAi('vehicle_ai'),
  unknown('unknown');

  final String value;
  const Source(this.value);

  factory Source.fromJson(String json) {
    return Source.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Source.unknown,
    );
  }
}

enum ReportStatus {
  submitted('submitted'),
  verified('verified'),
  assigned('assigned'),
  inProgress('in_progress'),
  resolved('resolved'),
  rejected('rejected'),
  escalated('escalated'),
  unknown('unknown');

  final String value;
  const ReportStatus(this.value);

  factory ReportStatus.fromJson(String json) {
    return ReportStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ReportStatus.unknown,
    );
  }
}

enum Channel {
  inApp('in_app'),
  email('email'),
  push('push'),
  sms('sms'),
  unknown('unknown');

  final String value;
  const Channel(this.value);

  factory Channel.fromJson(String json) {
    return Channel.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Channel.unknown,
    );
  }
}

enum NotificationType {
  reportReceived('report_received'),
  statusChanged('status_changed'),
  assigned('assigned'),
  duplicateMerged('duplicate_merged'),
  escalated('escalated'),
  resolved('resolved'),
  unknown('unknown');

  final String value;
  const NotificationType(this.value);

  factory NotificationType.fromJson(String json) {
    return NotificationType.values.firstWhere(
      (e) => e.value == json,
      orElse: () => NotificationType.unknown,
    );
  }
}

enum Category {
  damagedRoad('damaged_road', 'Damaged Road'),
  pothole('pothole', 'Pothole'),
  illegalParking('illegal_parking', 'Illegal Parking'),
  brokenRoadSign('broken_road_sign', 'Broken Road Sign'),
  fallenTree('fallen_tree', 'Fallen Tree'),
  garbage('garbage', 'Garbage'),
  vandalism('vandalism', 'Vandalism'),
  deadAnimal('dead_animal', 'Dead Animal'),
  damagedConcrete('damaged_concrete', 'Damaged Concrete'),
  electricHazard('electric_hazard', 'Electric Hazard'),
  other('other', 'Other'),
  unknown('unknown', 'Unknown');

  final String value;
  final String label;
  const Category(this.value, this.label);

  factory Category.fromJson(String json) {
    return Category.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Category.unknown,
    );
  }
}
