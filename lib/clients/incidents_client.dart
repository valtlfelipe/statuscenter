import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:statuspageapp/utils/string_extension.dart';

class IncidentsClient {
  String apiKey;
  String pageId;

  IncidentsClient(this.apiKey, this.pageId);

  Future<List<Incident>> getOpenIncidents() async {
    http.Response response = await http.get(
        'https://api.statuspage.io/v1/pages/${this.pageId}/incidents/unresolved?api_key=${this.apiKey}');
    // TODO: if (response.statusCode == 200) {
    List responseJson = json.decode(utf8.decode(response.bodyBytes));
    return responseJson.map((p) => new Incident.fromJson(p)).toList();
  }

  Future<List<Incident>> getIncidents() async {
    http.Response response = await http.get(
        'https://api.statuspage.io/v1/pages/${this.pageId}/incidents?api_key=${this.apiKey}');
    // TODO: if (response.statusCode == 200) {
    List responseJson = json.decode(utf8.decode(response.bodyBytes));
    return responseJson.map((p) => new Incident.fromJson(p)).toList();
  }

  Future<List<Incident>> getMaintenaces() async {
    http.Response response = await http.get(
        'https://api.statuspage.io/v1/pages/${this.pageId}/incidents/scheduled?api_key=${this.apiKey}');
    // TODO: if (response.statusCode == 200) {
    List responseJson = json.decode(utf8.decode(response.bodyBytes));
    return responseJson.map((p) => new Incident.fromJson(p)).toList();
  }

  Future<Incident> getIncident(String id) async {
    http.Response response = await http.get(
        'https://api.statuspage.io/v1/pages/${this.pageId}/incidents/$id?api_key=${this.apiKey}');
    // TODO: if (response.statusCode == 200) {
    return new Incident.fromJson(json.decode(utf8.decode(response.bodyBytes)));
  }
}

class IncidentHistory {
  final String id;
  final String body;
  final String status;
  final DateTime displayAt;
  final List<AffectedComponent> components;

  IncidentHistory({
    this.id,
    this.body,
    this.status,
    this.displayAt,
    this.components,
  });

  factory IncidentHistory.fromJson(Map<String, dynamic> json) {
    return IncidentHistory(
      id: json['id'],
      body: json['body'],
      status: json['status'],
      displayAt: json['display_at'] != null ? DateTime.parse(json['display_at']) : null,
      components: json['affected_components'] != null ? (json['affected_components'] as List)
            .map((c) => new AffectedComponent.fromJson(c))
            .toList() : null
    );
  }

  String getDisplayedAtFormated() {
    return new DateFormat('d MMMM yyyy HH:mm').format(this.displayAt.toLocal());
  }

  String getStatusFormated() {
    return this.status.capitalize();
  }
}

class AffectedComponent {
  final String code;
  final String name;
  final String oldStatus;
  final String newStatus;

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
      oldStatus: json['oldStatus'],
      newStatus: json['newStatus'],
    );
  }
}

// TODO: move to model/ folder
class Incident {
  final String id;
  final String name;
  final String status;
  final String impact;
  final String shortlink;
  final DateTime updatedAt;
  final List<IncidentHistory> history;

  Incident({
    this.id,
    this.name,
    this.status,
    this.impact,
    this.updatedAt,
    this.shortlink,
    this.history,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
        id: json['id'],
        name: json['name'],
        status: json['status'],
        impact: json['impact'],
        shortlink: json['shortlink'],
        updatedAt: DateTime.parse(json['updated_at']),
        history: json['incident_updates'] != null ? (json['incident_updates'] as List)
            .map((h) => new IncidentHistory.fromJson(h))
            .toList() : null);
  }

  String getUpdatedAtFormated() {
    return new DateFormat('d MMMM yyyy HH:mm').format(this.updatedAt.toLocal());
  }

  Color getColor() {
    switch (this.impact) {
      case 'critical':
        return Colors.red;
      case 'major':
        return Colors.deepOrange;
      case 'minor':
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }
}
