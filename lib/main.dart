import 'package:flutter/material.dart';
// import 'package:statuspageapp/pages/login.dart';
import 'package:statuspageapp/pages/incidents_list.dart';
import 'package:statuspageapp/pages/incident.dart';
import 'package:statuspageapp/pages/new_incident.dart';

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
      darkTheme: ThemeData.dark(),
      // home: LoginPage(),
      initialRoute: '/home',
      routes: <String, WidgetBuilder>{
        // '/': (BuildContext context) => LoginPage(), // TODO: fix login flow
        '/home': (BuildContext context) => IncidentsListPage(),
        '/incident': (BuildContext context) => IncidentPage(),
        '/incident/new': (BuildContext context) => NewIncidentPage(),
      },
    );
  }
}
