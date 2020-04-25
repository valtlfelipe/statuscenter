import 'package:flutter/material.dart';
import 'package:statuspageapp/models/component.dart';
import 'package:statuspageapp/models/incident_history.dart';
import 'package:statuspageapp/models/incident_impact.dart';
import 'package:statuspageapp/models/incident_status.dart';
import 'package:statuspageapp/utils/date_util.dart';

class Incident {
  String id;
  String name;
  String status;
  String impact;
  String shortlink;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime startedAt;
  DateTime resolvedAt;
  DateTime monitoringAt;
  DateTime scheduledFor;
  DateTime scheduledUntil;
  List<IncidentHistory> history;
  List<Component> components;
  String body;

  Incident({
    this.id,
    this.name,
    this.status,
    this.impact,
    this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.resolvedAt,
    this.monitoringAt,
    this.scheduledFor,
    this.scheduledUntil,
    this.shortlink,
    this.history,
    this.components,
    this.body,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      impact: json['impact'],
      shortlink: json['shortlink'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      monitoringAt: json['monitoring_at'] != null
          ? DateTime.parse(json['monitoring_at'])
          : null,
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'])
          : null,
      scheduledUntil: json['scheduled_until'] != null
          ? DateTime.parse(json['scheduled_until'])
          : null,
      history: json['incident_updates'] != null
          ? (json['incident_updates'] as List)
              .map((h) => new IncidentHistory.fromJson(h))
              .toList()
          : null,
      components: json['components'] != null
          ? (json['components'] as List)
              .map((c) => new Component.fromJson(c))
              .toList()
          : null,
      body: json['body'],
    );
  }

  DateTime getLatestDate() {
    if (this.resolvedAt != null) {
      return this.resolvedAt;
    } else if (this.monitoringAt != null) {
      return this.monitoringAt;
    } else if (this.scheduledFor != null) {
      return this.scheduledFor;
    } else if (this.updatedAt != null) {
      return this.updatedAt;
    } else if (this.startedAt != null) {
      return this.startedAt;
    }

    return this.createdAt;
  }

  String getLatestDateFormatted() {
    return DateUtil.format(this.getLatestDate());
  }

  Color getColor() {
    IncidentImpact impact =
        IncidentImpactList.firstWhere((c) => c.key == this.impact);
    return impact.color;
  }

  String getStatusFormatted() {
    IncidentStatus status =
        AllIncidentStatusList.firstWhere((c) => c.key == this.status);
    return status.name;
  }
}