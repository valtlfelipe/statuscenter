import 'package:flutter/material.dart';
import 'package:statuscenter/models/component_status.dart';

class AffectedComponent {
  String code;
  String name;
  String oldStatus;
  String newStatus;

  AffectedComponent({
    this.code,
    this.name,
    this.oldStatus,
    this.newStatus,
  });

  factory AffectedComponent.fromJson(Map<String, dynamic> json) {
    return AffectedComponent(
      code: json['code'],
      name: json['name'],
      oldStatus: json['old_status'],
      newStatus: json['new_status'],
    );
  }

  Icon getDisplayIcon() {
    ComponentStatus status =
        ComponentStatusList.firstWhere((c) => c.key == this.newStatus);
    return status.icon;
  }
}