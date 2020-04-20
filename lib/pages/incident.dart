import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'package:statuspageapp/models/incident_status.dart';

class IncidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _IncidentPageState();
}

// TODO: external this
class Choice {
  const Choice({this.title});

  final String title;
}

// TODO: external this
const List<Choice> choices = const <Choice>[
  const Choice(title: 'Open in browser'),
  const Choice(title: 'Share'),
];

class _IncidentPageState extends State<IncidentPage> {
  Future<Incident> _future;
  Incident incident;
  String id;

  @override
  void initState() {
    _future = _getPage();
    super.initState();
  }

  Future<Incident> _getPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('apiKey');
    this.incident = await new IncidentsClient(apiKey, prefs.getString('pageId'))
        .getIncident(this.id);
    return this.incident;
  }

  void _select(Choice choice) async {
    String url = this.incident.shortlink;
    // TODO: find another way to compare this
    if (choice == choices[0]) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else if (choice == choices[1]) {
      await Share.share(url, subject: this.incident.name);
    }
  }

  bool _showNewUpdateButton() {
    return this.incident.status != IncidentStatusResolved.key; // TODO: Check all other status
  }

  @override
  Widget build(BuildContext context) {
    this.id = ModalRoute.of(context).settings.arguments;

    return FutureBuilder(
      future: _future,
      builder: (context, incidentSnap) {
        if (incidentSnap.hasError) {
          return Center(
            child: Text(
                'Something wrong with message: ${incidentSnap.error.toString()}'), // TODO: improve error handling
          );
        } else if (incidentSnap.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Incident incident = incidentSnap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(this.incident.name),
            backgroundColor: this.incident.getColor(),
            actions: <Widget>[
              PopupMenuButton<Choice>(
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: _incidentWidget(),
          floatingActionButton: this._showNewUpdateButton()
              ? FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/incident/new',
                      arguments: this.incident,
                    );
                    if (result == 'refresh') {
                      _future = _getPage();
                    }
                  },
                  child: Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _incidentWidget() {
    return new Container(
      padding: new EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Update History', style: Theme.of(context).textTheme.title),
          SizedBox(height: 10),
          Expanded(
            child: _historyWidget(),
          ),
        ],
      ),
    );
  }

  Widget _historyWidget() {
    List<IncidentHistory> history = this.incident.history;
    if (history == null) {
      return null;
    }
    return ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          IncidentHistory item = history[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  title: Text(item.getStatusFormated()),
                  subtitle: Text(item.getDisplayedAtFormated()),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child:
                      Text(item.body, style: Theme.of(context).textTheme.body2),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: _affectedComponents(item),
                ),
              ],
            ),
          );
        });
  }

  Widget _affectedComponents(IncidentHistory history) {
    List<AffectedComponent> components = history.components;
    if (components == null) {
      return null;
    }
    return ListView.builder(
        shrinkWrap: true,
        itemCount: components.length,
        itemBuilder: (context, index) {
          AffectedComponent component = components[index];
          return Text(component.name,
              style: Theme.of(context).textTheme.caption);
        });
  }
}
