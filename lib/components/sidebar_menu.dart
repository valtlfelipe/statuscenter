import 'package:flutter/material.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/utils/color.dart';

class SidebarMenu extends StatelessWidget {
  final AuthData authData;
  final String currentPage;
  const SidebarMenu({Key key, this.authData, this.currentPage})
      : super(key: key);

  _handleTap(context, route) {
    if (this.currentPage == route) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: ACCENT_COLOR,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Status Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          this.authData != null ? this.authData.page.name : '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          this.authData != null
                              ? 'ID: ${this.authData.page.id}'
                              : '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              selected: this.currentPage == '/home' ? true : false,
              onTap: () => _handleTap(context, '/home'),
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Incidents'),
              selected: this.currentPage == '/incidents' ? true : false,
              onTap: () => _handleTap(context, '/incidents'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}
