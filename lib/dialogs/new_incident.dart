import 'package:flutter/material.dart';
import 'package:statuscenter/clients/incidents_client.dart';
import 'package:statuscenter/components/incident_status_selector.dart';
import 'package:statuscenter/components/message_field.dart';
import 'package:statuscenter/components/save_button.dart';
import 'package:statuscenter/components/select_components.dart';
import 'package:statuscenter/models/incident.dart';
import 'package:statuscenter/models/incident_status.dart';
import 'package:statuscenter/utils/validate_text_field.dart';

class NewIncidentDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NewIncidentDialogState();
}

class _NewIncidentDialogState extends State<NewIncidentDialog> {
  bool _isSaving;
  Incident _data = new Incident();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    _isSaving = false;
    this._data.status = IncidentStatusInvestigating.key;
    this._data.components = [];
    super.initState();
  }

  Future submit() async {
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isSaving = true;
      });
      _formKey.currentState.save();

      await new IncidentsClient().createNew(this._data);

      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New incident'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: this._formKey,
            child: Column(
              children: [
                new TextFormField(
                  autofocus: true,
                  decoration: new InputDecoration(labelText: 'Name'),
                  validator: validateTextField,
                  onSaved: (String value) {
                    this._data.name = value;
                  },
                ),
                new IncidentStatusSelector(
                  items: IncidentStatusList,
                  value: _data.status,
                  onChanged: (String value) {
                    setState(() => _data.status = value);
                  },
                ),
                new MessageField(
                  onSaved: (String value) {
                    this._data.body = value;
                  },
                ),
                new SelectComponents(
                  components: this._data.components,
                  onClose: (List result) {
                    setState(() {
                      _data.components = result;
                    });
                  },
                ),
                SizedBox(height: 20),
                SaveButton(
                  onPressed: this.submit,
                  isSaving: this._isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
