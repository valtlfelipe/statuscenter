import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'package:statuspageapp/models/incident_status.dart';

class NewIncidentUpdateDialog extends StatefulWidget {
  final Incident incident;

  NewIncidentUpdateDialog({Key key, this.incident}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _NewIncidentUpdateDialogState(this.incident);
}

class _NewIncidentUpdateDialogState extends State<NewIncidentUpdateDialog> {
  Incident incident;
  String selectedStatus;
  bool _isButtonDisabled;
  IncidentHistory _data = new IncidentHistory();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  _NewIncidentUpdateDialogState(this.incident);

  @override
  void initState() {
    _isButtonDisabled = false;
    super.initState();
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isButtonDisabled = true;
      });
      _formKey.currentState.save(); // Save our form now.
      this._data.status = selectedStatus;

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await new IncidentsClient(
              prefs.getString('apiKey'), prefs.getString('pageId'))
          .createNewUpdate(this.incident.id, this._data);

      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    // this.incident = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Incident update'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20),
        child: Form(
            key: this._formKey,
            child: Column(children: <Widget>[
              DropdownButtonFormField(
                decoration: new InputDecoration(labelText: 'Status'),
                items: IncidentStatusList.map((IncidentStatus value) {
                  return new DropdownMenuItem(
                    value: value.key,
                    child: new Text(value.name),
                  );
                }).toList(),
                isDense: true,
                value: selectedStatus != null
                    ? selectedStatus
                    : this.incident.status,
                onChanged: (String value) {
                  setState(() => selectedStatus = value);
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
              SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    child: new Text(
                      _isButtonDisabled ? 'Saving...' : 'Update',
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: this._isButtonDisabled ? null : this.submit,
                    color: Colors.blue,
                  )),
            ])),
      ),
    );
  }
}
