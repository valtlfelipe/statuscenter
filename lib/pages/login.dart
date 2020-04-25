import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:statuspageapp/models/api_key_validation_result.dart';
import 'package:statuspageapp/services/api_key_service.dart';
import 'package:statuspageapp/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _errorMessage;

  @override
  void initState() {
    _isButtonDisabled = false;
    super.initState();
  }

  String _validateApiKey(String value) {
    if (value.length < 10) {
      return 'Invalid API key';
    }
    return null;
  }

  Future submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      setState(() {
        _isButtonDisabled = true;
        _errorMessage = null;
      });
      _formKey.currentState.save();

      APIKeyValidationResult validation =
          await APIKeyValidationService.validate(_data.apiKey);

      if (validation.valid) {
        await AuthService.login(validation.apiKey, validation.page);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _isButtonDisabled = false;
          _errorMessage = validation.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Center'),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Image(
                    image: AssetImage(
                        'assets/logo.webp')), // TODO: reduze image size
              ),
              Text('Welcome to Status Center!',
                  style: Theme.of(context).textTheme.headline,
                  textAlign: TextAlign.center),
              SizedBox(height: 5),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.body2,
                  children: [
                    TextSpan(text: 'Here you can manage your '),
                    TextSpan(
                      text: 'statuspage.io page',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' with ease and on the go.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Divider(),
              SizedBox(height: 5),
              Form(
                key: this._formKey,
                child: Column(
                  children: [
                    TextFormField(
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                            labelText: 'Your account API key',
                            errorText: _errorMessage),
                        validator: this._validateApiKey,
                        onSaved: (String value) {
                          this._data.apiKey = value;
                        }),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(Icons.lock),
                        SizedBox(width: 5),
                        Text('Your key is only stored on this device.',
                            style: Theme.of(context).textTheme.body2),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          child: new Text(
                            _isButtonDisabled
                                ? 'Getting your data...'
                                : 'Let\'s go!',
                            style: new TextStyle(color: Colors.white),
                          ),
                          onPressed:
                              this._isButtonDisabled ? null : this.submit,
                          color: Colors.green,
                        )),
                    SizedBox(height: 10),
                    _helpWidget(),
                    SizedBox(height: 20),
                    Text('Not affiliated with Atlassian Statuspage',
                        style: Theme.of(context).textTheme.caption),
                  ],
                ),
              )
            ],
          )),
    );
  }

  _helpWidget() {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.body1,
        children: [
          TextSpan(
            text: 'Where do I find my API key?',
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _showHelpDialog();
              },
          ),
        ],
      ),
    );
  }

  _showHelpDialog() async {
    String statusPageURL = 'https://manage.statuspage.io/login';
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Where is my API key?'),
            contentPadding: EdgeInsets.all(20),
            children: [
              new RichText(
                text: new TextSpan(
                  style: Theme.of(context).textTheme.body1,
                  children: [
                    new TextSpan(text: '1. Log in to your account at '),
                    new TextSpan(
                      text: statusPageURL,
                      style: new TextStyle(color: Colors.blue),
                      recognizer: new TapGestureRecognizer()
                        ..onTap = () {
                          launch(statusPageURL);
                        },
                    ),
                  ],
                ),
              ),
              Text(
                  '2. Click on your avatar in the bottom left of your screen to access the user menu'),
              Text('3. Click API info'),
              Text('4. Enter the displayed API key on the requested field'),
              SizedBox(height: 10),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        });
  }
}
