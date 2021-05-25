import 'package:flutter/material.dart';
import 'package:statuscenter/models/incident_status.dart';

class IncidentStatusSelector extends StatelessWidget {
  final List<IncidentStatus> items;
  final String value;
  final Function onChanged;
  const IncidentStatusSelector(
      {Key key, this.items, this.value, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: 'Status'),
      items: this.items.map((IncidentStatus value) {
        return new DropdownMenuItem(
          value: value.key,
          child: Text(value.name),
        );
      }).toList(),
      isDense: true,
      value: this.value,
      onChanged: (String value) {
        this.onChanged(value);
      },
    );
  }
}
