import 'package:flutter/material.dart';
import 'package:statuspageapp/pages/login.dart';
import 'package:statuspageapp/pages/incidents_list.dart';
import 'package:statuspageapp/pages/incident.dart';
import 'package:statuspageapp/services/auth_service.dart';

bool _isAuthenticated = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _isAuthenticated = await AuthService.isLogged();
  runApp(StatusCenterApp());
}

class StatusCenterApp extends StatelessWidget {
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
      initialRoute: _isAuthenticated ? '/home' : '/login',
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => LoginPage(),
        '/home': (BuildContext context) => IncidentsListPage(),
        '/incident': (BuildContext context) => IncidentPage(),
      },
    );
  }
}
