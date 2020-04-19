import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'incidents_list/list_incidents.dart';

class IncidentsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _IncidentsListPageState();
}

class _IncidentsListPageState extends State<IncidentsListPage> {
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
    TODO: handle this better, maybe in login flow
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
          title: Text('Statuspage Manager'), // TODO: Maybe add page title
          bottom: TabBar(
            tabs: [
              Tab(text: 'Open'),
              Tab(text: 'Incidents'),
              Tab(text: 'Maintenances'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            new IncidentsListWidget(
                future: _openIncidentsFuture,
                onRefresh: _onOpenIncidentsRefresh),
            new IncidentsListWidget(
                future: _incidentsFuture, onRefresh: _onIncidentsRefresh),
            new IncidentsListWidget(
                future: _maintenancesFuture, onRefresh: _onMaintenacesRefresh),
          ],
        ),
      ),
    );
  }
}
