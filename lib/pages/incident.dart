import 'package:flutter/material.dart';
import 'package:statuspageapp/dialogs/new_incident_update.dart';
import 'package:statuspageapp/exceptions/request_exception.dart';
import 'package:statuspageapp/models/affected_component.dart';
import 'package:statuspageapp/models/incident.dart';
import 'package:statuspageapp/models/incident_history.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:statuspageapp/clients/incidents_client.dart';
import 'package:statuspageapp/models/incident_status.dart';

class IncidentPage extends StatefulWidget {
  final String id;

  IncidentPage({this.id});

  @override
  State<StatefulWidget> createState() => new _IncidentPageState(this.id);
}

class Choice {
  const Choice({this.title});

  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Open in browser'),
  const Choice(title: 'Share'),
];

class _IncidentPageState extends State<IncidentPage> {
  Future<Incident> _future;
  Incident incident;
  String id;

  _IncidentPageState(this.id);

  @override
  void initState() {
    _future = _getPage();
    super.initState();
  }

  Future<Incident> _getPage() async {
    try {
      this.incident = await new IncidentsClient().getIncident(this.id);
      return this.incident;
    } on RequestException catch (error) {
      Navigator.pop(context, error);
      return null;
    }
  }

  void _select(Choice choice) async {
    String url = this.incident.shortlink;
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
    return this.incident.status != IncidentStatusResolved.key &&
        this.incident.status !=
            IncidentStatusCompleted.key;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, incidentSnap) {
        if (incidentSnap.hasError) {
          return Center(
            child: Text(
                'Something wrong with message: ${incidentSnap.error.toString()}'),
          );
        } else if (incidentSnap.connectionState != ConnectionState.done ||
            this.incident == null) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

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
                    final result =
                        await Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) {
                              return new NewIncidentUpdateDialog(
                                  incident: this.incident);
                            },
                            fullscreenDialog: true));
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
    if (components == null ||
        components.length == 0 ||
        (components.length == 1 && components[0].newStatus == null)) {
      return Text('No components were affected by this update.',
          style: Theme.of(context).textTheme.caption);
    }
    return Column(
      children: components.map((AffectedComponent component) {
        return Row(children: [
          component.getDisplayIcon(),
          SizedBox(width: 5),
          Expanded(
              child: Text(component.name,
                  style: Theme.of(context).textTheme.caption,
                  overflow: TextOverflow.ellipsis))
        ]);
      }).toList(),
    );
  }
}
