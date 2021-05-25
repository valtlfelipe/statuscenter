import 'package:flutter/material.dart';
import 'package:statuscenter/clients/incidents_client.dart';
import 'package:statuscenter/components/incident_status_selector.dart';
import 'package:statuscenter/components/message_field.dart';
import 'package:statuscenter/components/save_button.dart';
import 'package:statuscenter/models/affected_component.dart';
import 'package:statuscenter/models/component.dart';
import 'package:statuscenter/models/incident.dart';
import 'package:statuscenter/models/incident_history.dart';
import 'package:statuscenter/models/incident_impact.dart';
import 'package:statuscenter/models/incident_status.dart';
import 'package:statuscenter/models/component_status.dart';

class NewIncidentUpdateDialog extends StatefulWidget {
  final Incident incident;

  NewIncidentUpdateDialog({Key key, this.incident}) : super(key: key);

  @override
  _NewIncidentUpdateDialogState createState() =>
      new _NewIncidentUpdateDialogState();
}

class _NewIncidentUpdateDialogState extends State<NewIncidentUpdateDialog> {
  bool _isSaving;
  IncidentHistory _data = new IncidentHistory();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    _isSaving = false;
    _data.components = widget.incident.components
        .map((Component c) =>
            AffectedComponent(code: c.id, name: c.name, newStatus: c.status))
        .toList();
    super.initState();
  }

  Future submit() async {
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isSaving = true;
      });
      _formKey.currentState.save();

      await new IncidentsClient()
          .createNewUpdate(widget.incident.id, this._data);

      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New update'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: this._formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inicident: ${widget.incident.name}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                new IncidentStatusSelector(
                  items: widget.incident.impact == IncidentImpactMaintenance.key
                      ? MaintenanceStatusList
                      : IncidentStatusList,
                  value: _data.status != null
                      ? _data.status
                      : widget.incident.status,
                  onChanged: (String value) {
                    setState(() => _data.status = value);
                  },
                ),
                new MessageField(
                  onSaved: (String value) {
                    this._data.body = value;
                  },
                ),
                _componentsWidget(),
                SizedBox(height: 20),
                SaveButton(
                  onPressed: this.submit,
                  isSaving: this._isSaving,
                  label: 'Update',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _componentsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'Components affected',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        _componentsListWidget(),
      ],
    );
  }

  _componentsListWidget() {
    List<AffectedComponent> components = this._data.components;

    if (components == null || components.length == 0) {
      return Text(
        'No components were affected by this update.',
        style: Theme.of(context).textTheme.caption,
      );
    }

    return Column(
      children: components.map((AffectedComponent c) {
        final int idx = components.indexOf(c);
        return DropdownButtonFormField(
          decoration: new InputDecoration(labelText: c.name),
          items: ComponentStatusList.map((ComponentStatus value) {
            return new DropdownMenuItem(
              value: value.key,
              child: new Text(value.name),
            );
          }).toList(),
          isDense: true,
          value: c.newStatus,
          onChanged: (String value) {
            setState(() => _data.components[idx].newStatus = value);
          },
        );
      }).toList(),
    );
  }
}
