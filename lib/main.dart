import 'package:flutter/material.dart';
import 'package:statuscenter/pages/login.dart';
import 'package:statuscenter/pages/incidents_list.dart';
import 'package:statuscenter/pages/incident.dart';
import 'package:statuscenter/pages/settings.dart';
import 'package:statuscenter/services/auth_service.dart';

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
        title: 'Status Center',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData.dark(),
        initialRoute: _isAuthenticated ? '/home' : '/login',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (context) => LoginPage());
              break;
            case '/home':
              return MaterialPageRoute(
                  builder: (context) => IncidentsListPage());
              break;
            case '/incident':
              String id = settings.arguments;
              return MaterialPageRoute(
                  builder: (context) => IncidentPage(id: id));
              break;
            case '/settings':
              return MaterialPageRoute(builder: (context) => SettingsPage());
              break;
            default:
              return null;
              break;
          }
        });
  }
}
