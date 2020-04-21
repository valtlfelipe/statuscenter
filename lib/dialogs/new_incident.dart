import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statuspageapp/clients/components_client.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'package:statuspageapp/dialogs/components_selector.dart';
import 'package:statuspageapp/models/component.dart';
import 'package:statuspageapp/models/incident_status.dart';

class NewIncidentDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NewIncidentDialogState();
}

class _NewIncidentDialogState extends State<NewIncidentDialog> {
  bool _isButtonDisabled;
  List<IncidentStatus> _incidentStatusList;
  Incident _data = new Incident();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    _isButtonDisabled = false;
    _incidentStatusList = IncidentStatusList; // TODO: change this
    this._data.status = IncidentStatusInvestigating.key;
    this._data.components = new List<Component>();
    super.initState();
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isButtonDisabled = true;
      });
      _formKey.currentState.save(); // Save our form now.

      SharedPreferences prefs = await SharedPreferences.getInstance();

      await new IncidentsClient(
              prefs.getString('apiKey'), prefs.getString('pageId'))
          .createNew(this._data);

      Navigator.pop(context, 'refresh');
    }
  }

  String _validateTextField(value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
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
                child: Column(children: [
                  new TextFormField(
                      autofocus: true,
                      decoration: new InputDecoration(labelText: 'Name'),
                      validator: this._validateTextField,
                      onSaved: (String value) {
                        this._data.name = value;
                      }),
                  DropdownButtonFormField(
                    decoration: new InputDecoration(labelText: 'Status'),
                    items: _incidentStatusList.map((IncidentStatus value) {
                      return new DropdownMenuItem(
                        value: value.key,
                        child: new Text(value.name),
                      );
                    }).toList(),
                    isDense: true,
                    value: _data.status,
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
                      validator: this._validateTextField,
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
                          _isButtonDisabled ? 'Saving...' : 'Create',
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
        SizedBox(
            width: double.infinity,
            child: RaisedButton(
              color: Colors.blue,
              child: new Text(
                'Select affected components',
                style: new TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final List<Component> result =
                    await Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) {
                          return new ComponentsSelector(
                              components: this._data.components);
                        },
                        fullscreenDialog: true));
                setState(() {
                  _data.components = result;
                });
              },
            )),
        Text('${this._data.components.length} components affected',
            style: Theme.of(context).textTheme.caption),
      ],
    );
  }
}
