import 'package:flutter/material.dart';

class ComponentStatus {
  final String key;
  final String name;
  final Icon icon;

  const ComponentStatus({this.key, this.name, this.icon});
}

const ComponentStatusOperational = ComponentStatus(
    key: 'operational',
    name: 'Operational',
    icon: Icon(Icons.check_circle, color: Colors.green, size: 18));
const ComponentStatusDegradedPerformance = ComponentStatus(
    key: 'degraded_performance',
    name: 'Degraded performance',
    icon: Icon(Icons.remove_circle, color: Colors.amber, size: 18));
const ComponentStatusPartialOutage = ComponentStatus(
    key: 'partial_outage',
    name: 'Partial outage',
    icon: Icon(Icons.error, color: Colors.deepOrange, size: 18));
const ComponentStatusMajorOutage = ComponentStatus(
    key: 'major_outage',
    name: 'Major outage',
    icon: Icon(Icons.cancel, color: Colors.red, size: 18));
const ComponentStatusUnderMaintenace = ComponentStatus(
    key: 'under_maintenance',
    name: 'Under maintenace',
    icon: Icon(Icons.build, color: Colors.blue, size: 18));

const List<ComponentStatus> ComponentStatusList = [
  ComponentStatusOperational,
  ComponentStatusDegradedPerformance,
  ComponentStatusPartialOutage,
  ComponentStatusMajorOutage,
  ComponentStatusUnderMaintenace,
];
