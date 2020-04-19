import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:statuspageapp/clients/incidents_client.dart';

class IncidentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _IncidentPageState();
}

class Choice {
  const Choice({this.title});

  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Open in browser'),
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

  // TODO: create a service to handle page id in shared preferences
  Future<Incident> _getPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('apiKey');
    this.incident = await new IncidentsClient(apiKey, prefs.getString('pageId'))
        .getIncident(this.id);
    return this.incident;
  }

  void _select(Choice choice) async {
    if (choice == choices[0]) {
      String url = this.incident.shortlink;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
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
                'Something wrong with message: ${incidentSnap.error.toString()}'),
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
                padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Text(item.body),
              )
            ],
          ),
        );
        }
    );
  }
}
