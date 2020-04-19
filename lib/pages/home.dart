import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statuspageapp/clients/pages_client.dart';
import 'package:statuspageapp/clients/incidents_client.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Incident>> _future;

  @override
  void initState() {
    _future = _getPages();
    super.initState();
  }

  // TODO: create a service to handle page id in shared preferences
  Future<List<Incident>> _getPages() async {
    print('########## AQUUIIIII ???');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('apiKey');
    if (prefs.getString('pageId') == null) {
      List<Page> pages = await new PagesClient(apiKey).getPages();
      prefs.setString('pageId', pages[0].id);
    }
    List<Incident> incidents =
        await new IncidentsClient(apiKey, prefs.getString('pageId')).getOpenIncidents();
    return incidents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Incidents'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new RefreshIndicator(
          child: _pageWidget(),
          onRefresh: () {
            return _future = _getPages();
          },
        ),
      ),
    );
  }

  Widget _pageWidget() {
    return FutureBuilder(
      future: _future,
      builder: (context, incidentSnap) {
        if (incidentSnap.hasError) {
          return Center(
            child: Text(
                'Something wrong with message: ${incidentSnap.error.toString()}'),
          );
        } else if (incidentSnap.connectionState != ConnectionState.done) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<Incident> incidents = incidentSnap.data;
        return _buildListView(incidents);
      },
    );
  }

  Widget _buildListView(List<Incident> incidents) {
    return ListView.builder(
      itemCount: incidents.length,
      itemBuilder: (context, index) {
        Incident incident = incidents[index];
        return Card(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 2.0,
                  color: incident.getColor(),
                ),
              ),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              onTap: () {
                return Navigator.pushNamed(
                  context,
                  '/incident',
                  arguments: (incident.id),
                );
              },
              title: Text(incident.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(incident.getUpdatedAtFormated()),
                  SizedBox(height: 10),
                  Text(
                    incident.status,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
