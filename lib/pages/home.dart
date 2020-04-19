import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statuspageapp/clients/pages_client.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'home/list_incidents.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Incident>> _openIncidentsFuture;
  Future<List<Incident>> _incidentsFuture;
  Future<List<Incident>> _maintenancesFuture;

  @override
  void initState() {
    _openIncidentsFuture = _getOpenIncidents();
    _incidentsFuture = _getIncidents();
    _maintenancesFuture = _getMaintenances();
    super.initState();
  }

  /*
    TODO: handle this better
    if (prefs.getString('pageId') == null) {
      List<Page> pages = await new PagesClient(apiKey).getPages();
      prefs.setString('pageId', pages[0].id);
    }
  */

  Future<List<Incident>> _getOpenIncidents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Incident> incidents = await new IncidentsClient(
            prefs.getString('apiKey'), prefs.getString('pageId'))
        .getOpenIncidents();
    return incidents;
  }

  Future<List<Incident>> _getIncidents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Incident> incidents = await new IncidentsClient(
            prefs.getString('apiKey'), prefs.getString('pageId'))
        .getIncidents();
    return incidents;
  }

  Future<List<Incident>> _getMaintenances() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Incident> incidents = await new IncidentsClient(
            prefs.getString('apiKey'), prefs.getString('pageId'))
        .getMaintenaces();
    return incidents;
  }

  _onOpenIncidentsRefresh() {
    return _openIncidentsFuture = _getOpenIncidents();
  }

  _onIncidentsRefresh() {
    return _incidentsFuture = _getIncidents();
  }

  _onMaintenacesRefresh() {
    return _maintenancesFuture = _getMaintenances();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Statuspage Manager'), // TODO: Maybe add page title
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.warning), text: 'Open'),
              Tab(icon: Icon(Icons.list), text: 'Incidents'),
              Tab(icon: Icon(Icons.event), text: 'Maintenances'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            new IncidentsListWidget(_openIncidentsFuture, _onOpenIncidentsRefresh).build(),
            new IncidentsListWidget(_incidentsFuture, _onIncidentsRefresh).build(),
            new IncidentsListWidget(_maintenancesFuture, _onIncidentsRefresh).build(),
          ],
        ),
      ),
    );
  }
}
