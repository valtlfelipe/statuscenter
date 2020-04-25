import 'package:flutter/material.dart';
import 'package:statuspageapp/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _getAppInfo();
  }

  _getAppInfo() async {
    PackageInfo appinfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${appinfo.version} #${appinfo.buildNumber}';
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        padding: new EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image(
                      image: AssetImage(
                          'assets/logo.webp')), // TODO: reduze image size
                ),
                Text('Status Center',
                    style: Theme.of(context).textTheme.headline,
                    textAlign: TextAlign.center),
                Text(
                  'Version $_version',
                  style: Theme.of(context).textTheme.body1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '© 2020 Felipe Valtl de Mello',
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                )
              ],
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                'Remove API key',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _confirmAPIKeyRemovalDialog,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.mode_comment),
              title: Text('Share feedback'),
              onTap: () {
                _launchURL(
                    'mailto:statuscenterapp@felipe.im?subject=App%20feedback');
              },
            ),
            Divider(),
            ListTile(
              title: Text('Terms of service'),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                _launchURL(
                    'https://github.com/valtlfelipe/statuscenter/legal/terms-of-service.md');
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                _launchURL(
                    'https://github.com/valtlfelipe/statuscenter/legal/privacy-policy.md');
              },
            ),
            ListTile(
              title: Text('Licenses'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(
                    context: context,
                    applicationVersion: _version);
              },
            )
          ],
        ),
      ),
    );
  }

  _confirmAPIKeyRemovalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool _isLoadingRemoval = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('You will have to login with an API key again.'),
            actions: [
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Remove', style: TextStyle(color: Colors.red)),
                onPressed: _isLoadingRemoval
                    ? null
                    : () async {
                        setState(() {
                          _isLoadingRemoval = true;
                        });
                        await AuthService.logout();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (Route<dynamic> route) => false);
                      },
              ),
            ],
          );
        });
      },
    );
  }
}
