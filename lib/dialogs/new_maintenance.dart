import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:statuscenter/clients/incidents_client.dart';
import 'package:statuscenter/components/message_field.dart';
import 'package:statuscenter/components/save_button.dart';
import 'package:statuscenter/components/select_components.dart';
import 'package:statuscenter/models/incident.dart';
import 'package:statuscenter/models/incident_status.dart';
import 'package:statuscenter/utils/date_util.dart';
import 'package:statuscenter/utils/validate_text_field.dart';

class NewMaintenanceDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NewMaintenanceDialogState();
}

class _NewMaintenanceDialogState extends State<NewMaintenanceDialog> {
  bool _isSaving;
  Incident _data = new Incident();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _startDateTimeFormCtrl = TextEditingController();
  TextEditingController _endDateTimeFormCtrl = TextEditingController();

  @override
  void initState() {
    _isSaving = false;
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
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isSaving = true;
      });
      _formKey.currentState.save();

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
                new MessageField(
                  onSaved: (String value) {
                    this._data.body = value;
                  },
                ),
                new SelectComponents(
                  components: this._data.components,
                  allowStatusChange: false,
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
