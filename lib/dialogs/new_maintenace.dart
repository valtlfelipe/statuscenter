import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:statuscenter/clients/incidents_client.dart';
import 'package:statuscenter/dialogs/components_selector.dart';
import 'package:statuscenter/models/component.dart';
import 'package:statuscenter/models/incident.dart';
import 'package:statuscenter/models/incident_status.dart';
import 'package:statuscenter/ui/color.dart';
import 'package:statuscenter/utils/date_util.dart';

class NewMaintenaceDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NewMaintenaceDialogState();
}

class _NewMaintenaceDialogState extends State<NewMaintenaceDialog> {
  bool _isButtonDisabled;
  Incident _data = new Incident();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _startDateTimeFormCtrl = TextEditingController();
  TextEditingController _endDateTimeFormCtrl = TextEditingController();

  @override
  void initState() {
    _isButtonDisabled = false;
    this._data.status = IncidentStatusInvestigating.key;
    this._data.components = [];
    this._data.scheduledFor = DateTime.now();
    this._data.scheduledUntil =
        this._data.scheduledFor.add(new Duration(days: 1));
    _startDateTimeFormCtrl.text = DateUtil.format(this._data.scheduledFor);
    _endDateTimeFormCtrl.text = DateUtil.format(this._data.scheduledUntil);
    super.initState();
  }

  @override
  void dispose() {
    _startDateTimeFormCtrl.dispose();
    _endDateTimeFormCtrl.dispose();
    super.dispose();
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isButtonDisabled = true;
      });
      _formKey.currentState.save(); // Save our form now.

      await new IncidentsClient().createNewMaintenance(this._data);

      Navigator.pop(context, 'refresh');
    }
  }

  _selectStartDate() async {
    DatePicker.showDateTimePicker(context,
        // https://github.com/Realank/flutter_datetime_picker/issues/100
        minTime: DateTime.now().subtract(new Duration(minutes: 10)),
        currentTime: this._data.scheduledFor, onConfirm: (date) {
      setState(() {
        _data.scheduledFor = date;
        _startDateTimeFormCtrl.text = DateUtil.format(date);
      });
    });
  }

  _selectEndDate() async {
    DatePicker.showDateTimePicker(context,
        // https://github.com/Realank/flutter_datetime_picker/issues/100
        minTime: DateTime.now().subtract(new Duration(minutes: 10)),
        currentTime: this._data.scheduledUntil, onConfirm: (date) {
      setState(() {
        _data.scheduledUntil = date;
        _endDateTimeFormCtrl.text = DateUtil.format(date);
      });
    });
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
        title: Text('New maintenance'),
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
                  new TextFormField(
                    readOnly: true,
                    controller: _startDateTimeFormCtrl,
                    decoration: new InputDecoration(labelText: 'Start Date'),
                    onTap: _selectStartDate,
                  ),
                  new TextFormField(
                    readOnly: true,
                    controller: _endDateTimeFormCtrl,
                    decoration: new InputDecoration(labelText: 'End Date'),
                    onTap: _selectEndDate,
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
                      child: ElevatedButton(
                        child: new Text(
                          _isButtonDisabled ? 'Saving...' : 'Create',
                          style: new TextStyle(color: Colors.white),
                        ),
                        onPressed: this._isButtonDisabled ? null : this.submit,
                        style: ElevatedButton.styleFrom(
                          primary: ACCENT_COLOR,
                        ),
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: new Text(
                'Select affected components',
                style: new TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final List<Component> result =
                    await Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) {
                          return new ComponentsSelector(
                              components: this._data.components,
                              allowStatusChange: false);
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
