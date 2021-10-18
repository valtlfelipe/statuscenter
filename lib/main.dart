import 'package:flutter/material.dart';
import 'package:statuscenter/pages/home.dart';
import 'package:statuscenter/pages/login.dart';
import 'package:statuscenter/pages/incidents_list.dart';
import 'package:statuscenter/pages/incident.dart';
import 'package:statuscenter/pages/settings.dart';
import 'package:statuscenter/services/auth_service.dart';
import 'package:statuscenter/utils/color.dart';

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
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: APP_COLOR,
    );
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
    );
    return MaterialApp(
        title: 'Status Center',
        theme: lightTheme.copyWith(
          colorScheme: lightTheme.colorScheme.copyWith(
            secondary: ACCENT_COLOR,
            primary: APP_COLOR,
          ),
        ),
        darkTheme: darkTheme.copyWith(
          colorScheme: darkTheme.colorScheme.copyWith(
            secondary: ACCENT_COLOR,
            primary: APP_COLOR,
          ),
        ),
        // themeMode: ThemeMode.dark,
        initialRoute: _isAuthenticated ? '/home' : '/login',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (context) => LoginPage());
              break;
            case '/home':
              return MaterialPageRoute(
                  settings: RouteSettings(name: '/home'),
                  builder: (context) => HomePage());
              break;
            case '/incidents':
              int currentTab = settings.arguments;
              return MaterialPageRoute(
                  settings: RouteSettings(name: '/incidents'),
                  builder: (context) =>
                      IncidentsListPage(currentTab: currentTab));
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
