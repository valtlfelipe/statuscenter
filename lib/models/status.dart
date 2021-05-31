import 'package:flutter/material.dart';
import 'package:statuscenter/models/component.dart';
import 'package:statuscenter/models/incident_impact.dart';

class Status {
  final String indicator;
  final String description;
  final List<Component> components;
  final int incidentsCount;
  final int scheduledMaintenancesCount;

  Status(
      {this.indicator,
      this.description,
      this.components,
      this.incidentsCount,
      this.scheduledMaintenancesCount});

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
        indicator: json['status']['indicator'],
        description: json['status']['description'],
        incidentsCount: (json['incidents'] as List).length,
        scheduledMaintenancesCount:
            (json['scheduled_maintenances'] as List).length,
        components: json['components'] != null
            ? (json['components'] as List)
                .where((c) => c['group'] == false)
                .map((c) => new Component.fromJson(c))
                .toList()
            : null);
  }

  Color getColor() {
    IncidentImpact impact =
        IncidentImpactList.firstWhere((c) => c.key == this.indicator);
    return impact.color;
  }
}
