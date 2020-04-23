import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              trailing: Icon(Icons.more_vert),
            ),
            Divider(),
            ListTile(
              title: Text('Licenses'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(context: context, applicationVersion: '1.0'); // TODO: Check for app Version
              },
            )
          ],
        ),
      ),
    );
  }
}
