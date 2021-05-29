import 'package:flutter/material.dart';
import 'package:statuscenter/models/component_status.dart';

class Component {
  String id;
  String name;
  String status;
  String groupId;
  bool group;

  Component({
    this.id,
    this.name,
    this.status,
    this.groupId,
    this.group,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      groupId: json['group_id'],
      group: json['group'],
    );
  }

  Icon getDisplayIcon() {
    ComponentStatus status =
        ComponentStatusList.firstWhere((c) => c.key == this.status);
    return status.icon;
  }
}
