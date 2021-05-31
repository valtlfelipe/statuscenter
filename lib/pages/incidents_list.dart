import 'package:flutter/material.dart';
import 'package:statuscenter/clients/incidents_client.dart';
import 'package:statuscenter/components/sidebar_menu.dart';
import 'package:statuscenter/dialogs/new_incident.dart';
import 'package:statuscenter/dialogs/new_maintenance.dart';
import 'package:statuscenter/exceptions/request_exception.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/models/incident.dart';
import 'package:statuscenter/services/auth_service.dart';
import 'package:statuscenter/components/incidents_list.dart';

class IncidentsListPage extends StatefulWidget {
  final int currentTab;
  IncidentsListPage({this.currentTab = 0});

  @override
  State<StatefulWidget> createState() => new _IncidentsListPageState();
}

class _IncidentsListPageState extends State<IncidentsListPage>
    with SingleTickerProviderStateMixin {
  IncidentsListWidgetController _openIncidentsController =
      new IncidentsListWidgetController();
  IncidentsListWidgetController _incidentsController =
      new IncidentsListWidgetController();
  IncidentsListWidgetController _maintenancesController =
      new IncidentsListWidgetController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  TabController _tabController;
  final List<Tab> _tabs = <Tab>[
    Tab(text: 'Open'),
    Tab(text: 'Incidents'),
    Tab(text: 'Maintenances'),
  ];
  AuthData _authData;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: _tabs.length);
    if (widget.currentTab != null && widget.currentTab != 0) {
      _tabController.animateTo(widget.currentTab);
    }
    _loadAuthData();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future _loadAuthData() async {
    if (this._authData == null) {
      AuthData authData = await AuthService.getData();
      setState(() {
        _authData = authData;
      });
    }
  }

  Future<List<Incident>> _requestIncidents(String type) async {
    try {
      List<Incident> incidents;
      switch (type) {
        case 'open':
          incidents = await new IncidentsClient().getOpenIncidents();
          break;

        case 'incidents':
          incidents = await new IncidentsClient().getIncidents();
          break;

        case 'maintenances':
          incidents = await new IncidentsClient().getMaintenances();
          break;
      }
      return incidents;
    } on RequestException catch (error) {
      _scaffoldMessengerKey.currentState
          .showSnackBar(SnackBar(content: Text(error.toString())));
      return null;
    }
  }

  Future<List<Incident>> _getOpenIncidents() {
    return this._requestIncidents('open');
  }

  Future<List<Incident>> _getIncidents() {
    return this._requestIncidents('incidents');
  }

  Future<List<Incident>> _getMaintenances() async {
    return this._requestIncidents('maintenances');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        key: _scaffoldMessengerKey,
        appBar: AppBar(
          title: Text('Status Center'),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs,
          ),
        ),
        drawer: new SidebarMenu(
          authData: this._authData,
          currentPage: '/incidents',
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            new IncidentsListWidget(
                controller: _openIncidentsController,
                onRefresh: _getOpenIncidents,
                scaffoldMessengerKey: _scaffoldMessengerKey),
            new IncidentsListWidget(
                controller: _incidentsController,
                onRefresh: _getIncidents,
                scaffoldMessengerKey: _scaffoldMessengerKey),
            new IncidentsListWidget(
                controller: _maintenancesController,
                onRefresh: _getMaintenances,
                scaffoldMessengerKey: _scaffoldMessengerKey),
          ],
        ),
        floatingActionButton: _getAddButton(),
      ),
    );
  }

  _getAddButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.of(context).push(new MaterialPageRoute(
          builder: (BuildContext context) {
            // Maintenances tab
            if (this._tabController.index == 2) {
              return new NewMaintenanceDialog();
            }
            return new NewIncidentDialog();
          },
          fullscreenDialog: true,
        ));
        if (result == 'refresh') {
          if (this._tabController.index == 0) {
            _openIncidentsController.refresh();
          } else if (this._tabController.index == 1) {
            _incidentsController.refresh();
          } else if (this._tabController.index == 2) {
            _maintenancesController.refresh();
          }
        }
      },
      child: Icon(Icons.add),
    );
  }
}
