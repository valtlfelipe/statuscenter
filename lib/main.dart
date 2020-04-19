import 'package:flutter/material.dart';
import 'package:statuspageapp/pages/login.dart';
import 'package:statuspageapp/pages/home.dart';
import 'package:statuspageapp/pages/incident.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statuspage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: LoginPage(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => LoginPage(),
        '/home': (BuildContext context) => HomePage(),
        '/incident': (BuildContext context) => IncidentPage(),
      },
    );
  }
}
