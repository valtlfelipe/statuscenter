import 'package:flutter/material.dart';
import 'package:statuscenter/dialogs/new_incident_update.dart';
import 'package:statuscenter/exceptions/request_exception.dart';
import 'package:statuscenter/models/affected_component.dart';
import 'package:statuscenter/models/incident.dart';
import 'package:statuscenter/models/incident_history.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:statuscenter/clients/incidents_client.dart';
import 'package:statuscenter/models/incident_status.dart';

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
  bool _isRefreshing;
  Incident incident;
  String id;

  _IncidentPageState(this.id);

  @override
  void initState() {
    _future = _getPage();
    _isRefreshing = false;
    super.initState();
  }

  Future<Incident> _getPage() async {
    try {
      this.incident = await new IncidentsClient().getIncident(this.id);
      _isRefreshing = false;
      return this.incident;
    } on RequestException catch (error) {
      Navigator.pop(context, error);
      return null;
    }
  }

  Future _delete() async {
    try {
      await new IncidentsClient().deleteIncident(this.id);
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
        this.incident.status != IncidentStatusCompleted.key;
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
            this.incident == null ||
            _isRefreshing) {
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
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showRemoveDialog(context);
                  }),
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
                      setState(() {
                        _isRefreshing = true;
                        _future = _getPage();
                      });
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
          Text('Update History', style: Theme.of(context).textTheme.headline6),
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
                  child: Text(item.body,
                      style: Theme.of(context).textTheme.bodyText1),
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

  void showRemoveDialog(BuildContext context) async {
    // set up the buttons
    // show the dialog
    dynamic removed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        bool _isLoadingRemoval = false;
        return StatefulBuilder(builder: (context, setState) {
          Widget cancelButton = TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          );
          Widget deleteButton = TextButton(
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: _isLoadingRemoval
                ? null
                : () async {
                    setState(() {
                      _isLoadingRemoval = true;
                    });
                    await _delete();
                    Navigator.pop(context, true);
                  },
          );
          return AlertDialog(
            title: Text("Are you sure?"),
            content: Text(
                "This cannot be undone and will remove all associated data."),
            actions: [
              cancelButton,
              deleteButton,
            ],
          );
        });
      },
    );
    if (removed == true) {
      Navigator.pop(context, 'refresh');
    }
  }
}
