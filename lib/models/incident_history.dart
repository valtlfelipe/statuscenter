import 'package:statuspageapp/models/affected_component.dart';
import 'package:statuspageapp/utils/date_util.dart';
import 'package:statuspageapp/utils/string_extension.dart';

class IncidentHistory {
  String id;
  String body;
  String status;
  DateTime displayAt;
  List<AffectedComponent> components;

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
        displayAt: json['display_at'] != null
            ? DateTime.parse(json['display_at'])
            : null,
        components: json['affected_components'] != null
            ? (json['affected_components'] as List)
                .map((c) => new AffectedComponent.fromJson(c))
                .toList()
            : null);
  }

  String getDisplayedAtFormated() {
    return DateUtil.format(this.displayAt);
  }

  String getStatusFormated() {
    return this.status.capitalize();
  }
}