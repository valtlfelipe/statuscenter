import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginData {
  String apiKey = '';
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _LoginData _data = new _LoginData();

  String _validateApiKey(String value) {
    if (value.length < 8) {
      return 'Invalid API Key.';
    }

    return null;
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('apiKey', _data.apiKey);
      prefs.setString('apiKey', 'aced4460-ba38-48ed-9b45-575dfe25af83');

      Navigator.pushReplacementNamed(context, '/home');

      print('apiKey: ${_data.apiKey}');
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
                    onPressed: this.submit,
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
