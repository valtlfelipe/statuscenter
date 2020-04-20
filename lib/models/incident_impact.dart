import 'package:flutter/material.dart';

class IncidentImpact {
  final String key;
  final String name;
  final Color color;

  const IncidentImpact({this.key, this.name, this.color});
}

const IncidentImpactMinor =
    IncidentImpact(key: 'minor', name: 'Minor', color: Colors.orange);
const IncidentImpactMajor =
    IncidentImpact(key: 'major', name: 'Major', color: Colors.deepOrange);
const IncidentImpactCritical =
    IncidentImpact(key: 'critical', name: 'Critical', color: Colors.red);
const IncidentImpactMaintenance =
    IncidentImpact(key: 'maintenance', name: 'Maintenance', color: Colors.blue);
const IncidentImpactNone =
    IncidentImpact(key: 'none', name: 'None', color: Colors.blue);

const List<IncidentImpact> IncidentImpactList = [
  IncidentImpactMinor,
  IncidentImpactMajor,
  IncidentImpactCritical,
  IncidentImpactMaintenance,
  IncidentImpactNone,
];
