import 'package:flutter/material.dart';
import 'package:statuspageapp/pages/login.dart';
import 'package:statuspageapp/pages/incidents_list.dart';
import 'package:statuspageapp/pages/incident.dart';
import 'package:statuspageapp/pages/settings.dart';
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
