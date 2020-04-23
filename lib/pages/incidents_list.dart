import 'package:flutter/material.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'package:statuspageapp/dialogs/new_incident.dart';
import 'package:statuspageapp/dialogs/new_maintenace.dart';
import 'package:statuspageapp/models/auth_data.dart';
import 'package:statuspageapp/services/auth_service.dart';
import 'incidents_list/list_incidents.dart';

class IncidentsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _IncidentsListPageState();
}

class _IncidentsListPageState extends State<IncidentsListPage>
    with SingleTickerProviderStateMixin {
  Future<List<Incident>> _openIncidentsFuture;
  Future<List<Incident>> _incidentsFuture;
  Future<List<Incident>> _maintenancesFuture;

  TabController _tabController;
  final List<Tab> _tabs = <Tab>[
    Tab(text: 'Open'),
    Tab(text: 'Incidents'),
    Tab(text: 'Maintenances'),
  ];
  AuthData _authData;

  @override
  void initState() {
    _openIncidentsFuture = _getOpenIncidents();
    _incidentsFuture = _getIncidents();
    _maintenancesFuture = _getMaintenances();
    _tabController = new TabController(vsync: this, length: _tabs.length);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<AuthData> _getAuthData() async {
    if (this._authData == null) {
      return this._authData = await AuthService.getData();
    }
    return this._authData;
  }

  Future<List<Incident>> _getOpenIncidents() async {
    AuthData authData = await _getAuthData();
    List<Incident> incidents =
        await new IncidentsClient(authData.apiKey, authData.page.id)
            .getOpenIncidents();
    return incidents;
  }

  Future<List<Incident>> _getIncidents() async {
    AuthData authData = await _getAuthData();
    List<Incident> incidents =
        await new IncidentsClient(authData.apiKey, authData.page.id)
            .getIncidents();
    return incidents;
  }

  Future<List<Incident>> _getMaintenances() async {
    AuthData authData = await _getAuthData();
    List<Incident> incidents =
        await new IncidentsClient(authData.apiKey, authData.page.id)
            .getMaintenaces();
    return incidents;
  }

  // TODO: refac this, since this is stupid
  _onOpenIncidentsRefresh() {
    setState(() {
      _openIncidentsFuture = _getOpenIncidents();
    });
    return _openIncidentsFuture = _getOpenIncidents();
  }

  _onIncidentsRefresh() {
    setState(() {
      _incidentsFuture = _getIncidents();
    });
    return _incidentsFuture = _getIncidents();
  }

  _onMaintenacesRefresh() async {
    setState(() {
      _maintenancesFuture = _getMaintenances();
    });
    return _maintenancesFuture = _getMaintenances();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Status Center'), // TODO: Maybe add page title
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs,
            ),
          ),
          drawer: _getDrawer(),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              new IncidentsListWidget(
                  future: _openIncidentsFuture,
                  onRefresh: _onOpenIncidentsRefresh),
              new IncidentsListWidget(
                  future: _incidentsFuture, onRefresh: _onIncidentsRefresh),
              new IncidentsListWidget(
                  future: _maintenancesFuture,
                  onRefresh: _onMaintenacesRefresh),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result =
                  await Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) {
                        // Maintenaces tab
                        if (this._tabController.index == 2) {
                          return new NewMaintenaceDialog();
                        }
                        return new NewIncidentDialog();
                      },
                      fullscreenDialog: true));
              if (result == 'refresh' && this._tabController.index == 2) {
                _onMaintenacesRefresh();
              } else if (result == 'refresh') {
                _onOpenIncidentsRefresh();
              }
            },
            child: Icon(Icons.add),
          )),
    );
  }

  _getDrawer() {
    return Drawer(
      child: Container(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
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
                  SizedBox(height: 20),
                  Text(
                    this._authData != null ? this._authData.page.name : '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    this._authData != null ? 'ID: ${this._authData.page.id}' : '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('Incidents'),
              selected: true,
              onTap: () => Navigator.pop(context),
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
