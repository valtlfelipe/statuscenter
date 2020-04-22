import 'package:flutter/material.dart';
import 'package:statuspageapp/models/api_key_validation_result.dart';
import 'package:statuspageapp/services/api_key_service.dart';
import 'package:statuspageapp/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginData {
  String apiKey = '';
}

class _LoginPageState extends State<LoginPage> {
  bool _isButtonDisabled;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _LoginData _data = new _LoginData();

  @override
  void initState() {
    _isButtonDisabled = false;
    super.initState();
  }

  String _validateApiKey(String value) {
    if (value.length < 8) {
      return 'Invalid API Key.';
    }

    return null;
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isButtonDisabled = true;
      });
      _formKey.currentState.save(); // Save our form now.

      APIKeyValidationResult validation =
          await APIKeyValidationService.validate(_data.apiKey);
      if (validation.valid) {
        await AuthService.login(validation.apiKey, validation.page);
        Navigator.pushReplacementNamed(context, '/home');
      } // TODO: handle not valid
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Login'),
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[
                new TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: new InputDecoration(labelText: 'Your API Key'),
                    validator: this._validateApiKey,
                    onSaved: (String value) {
                      this._data.apiKey = value;
                    }),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Login',
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: this._isButtonDisabled ? null : this.submit,
                    color: Colors.blue,
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }
}
