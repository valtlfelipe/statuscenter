import 'package:flutter/material.dart';
import 'package:statuspageapp/models/incident.dart';

class IncidentsListWidget extends StatelessWidget {
  final Future future;
  final Function onRefresh;
  final GlobalKey<ScaffoldState> scaffoldKey;

  IncidentsListWidget({
    Key key,
    this.future,
    this.onRefresh,
    this.scaffoldKey,
  }) : super(key: ObjectKey(future));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: new EdgeInsets.all(20.0),
      child: new RefreshIndicator(
        child: FutureBuilder(
          future: future,
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
            if (incidents == null || incidents.length == 0) {
              return _emptyList(context);
            }
            return _buildListView(incidents);
          },
        ),
        onRefresh: () {
          return onRefresh();
        },
      ),
    );
  }

  Widget _emptyList(context) {
    return ListView(
      children: [
        Center(
          child: Column(
            children: <Widget>[
              Icon(Icons.sentiment_satisfied, size: 64),
              SizedBox(height: 10),
              Text('Nothing to see here.',
                  style: Theme.of(context).textTheme.headline),
            ],
          ),
        )
      ],
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
              onTap: () async {
                dynamic error = await Navigator.pushNamed(
                  context,
                  '/incident',
                  arguments: incident.id,
                );
                if(error != null) {
                  scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error.toString())));
                }
              },
              title: Text(incident.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(incident.getLatestDateFormatted()),
                  SizedBox(height: 10),
                  Text(
                    incident.getStatusFormatted(),
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
