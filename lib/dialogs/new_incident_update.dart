import 'package:flutter/material.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'package:statuspageapp/models/affected_component.dart';
import 'package:statuspageapp/models/component.dart';
import 'package:statuspageapp/models/incident.dart';
import 'package:statuspageapp/models/incident_history.dart';
import 'package:statuspageapp/models/incident_impact.dart';
import 'package:statuspageapp/models/incident_status.dart';
import 'package:statuspageapp/models/component_status.dart';

class NewIncidentUpdateDialog extends StatefulWidget {
  final Incident incident;

  NewIncidentUpdateDialog({Key key, this.incident}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _NewIncidentUpdateDialogState(this.incident);
}

class _NewIncidentUpdateDialogState extends State<NewIncidentUpdateDialog> {
  Incident incident;
  bool _isButtonDisabled;
  List<IncidentStatus> _incidentStatusList;
  IncidentHistory _data = new IncidentHistory();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  _NewIncidentUpdateDialogState(this.incident);

  @override
  void initState() {
    _isButtonDisabled = false;
    _data.components = this
        .incident
        .components
        .map((Component c) =>
            AffectedComponent(code: c.id, name: c.name, newStatus: c.status))
        .toList();
    _incidentStatusList = this.incident.impact == IncidentImpactMaintenance.key
        ? MaintenanceStatusList
        : IncidentStatusList;
    super.initState();
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isButtonDisabled = true;
      });
      _formKey.currentState.save(); // Save our form now.

      await new IncidentsClient()
          .createNewUpdate(this.incident.id, this._data);

      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New update'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20),
        child: SingleChildScrollView(
            child: Form(
                key: this._formKey,
                child: Column(children: [
                  DropdownButtonFormField(
                    decoration: new InputDecoration(labelText: 'Status'),
                    items: _incidentStatusList.map((IncidentStatus value) {
                      return new DropdownMenuItem(
                        value: value.key,
                        child: new Text(value.name),
                      );
                    }).toList(),
                    isDense: true,
                    value: _data.status != null
                        ? _data.status
                        : this.incident.status,
                    onChanged: (String value) {
                      setState(() => _data.status = value);
                    },
                  ),
                  SizedBox(
                    height: 150,
                    child: TextFormField(
                      decoration: new InputDecoration(labelText: 'Message'),
                      keyboardType: TextInputType.multiline,
                      minLines: null,
                      maxLines: null,
                      expands: true,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        this._data.body = value;
                      },
                    ),
                  ),
                  _componentsWidget(),
                  SizedBox(height: 20),
                  SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        child: new Text(
                          _isButtonDisabled ? 'Saving...' : 'Update',
                          style: new TextStyle(color: Colors.white),
                        ),
                        onPressed: this._isButtonDisabled ? null : this.submit,
                        color: Colors.green,
                      )),
                ]))),
      ),
    );
  }

  _componentsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text('Components affected',
            style: Theme.of(context).textTheme.subtitle),
        // SizedBox(height: 10),
        _componentsListWidget(),
      ],
    );
  }

  _componentsListWidget() {
    List<AffectedComponent> components = this._data.components;

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
