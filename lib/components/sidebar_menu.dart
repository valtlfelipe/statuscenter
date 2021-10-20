import 'package:flutter/material.dart';
import 'package:statuscenter/dialogs/select_page_dialog.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/services/auth_service.dart';
import 'package:statuscenter/utils/color.dart';
import 'package:statuscenter/models/page.dart' as PageModel;

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

  _changedPage(context, PageModel.Page page) async {
    await AuthService.setPage(page);
    return Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: ACCENT_COLOR,
            ),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Status Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SelectPageDialog(
                                currentPage: this.authData.page,
                                onChange: (PageModel.Page page) {
                                  this._changedPage(context, page);
                                },
                              );
                            },
                          );
                        },
                        title: this.authData != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    this.authData.page.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${this.authData.page.id}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : Text('Select page'),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
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
    );
  }
}
