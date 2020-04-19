import 'package:flutter/material.dart';
import 'package:statuspageapp/clients/incidents_client.dart';

class IncidentsListWidget {
  Future _future;
  Function onRefresh;

  IncidentsListWidget(
    this._future,
    this.onRefresh,
  );

  Widget build() {
    return Container(
      padding: new EdgeInsets.all(20.0),
      child: new RefreshIndicator(
        child: FutureBuilder(
          future: _future,
          builder: (context, incidentSnap) {
            if (incidentSnap.hasError) {
              return Center(
                child: Text(
                    'Something wrong with message: ${incidentSnap.error.toString()}'), // TODO: handle better errors
              );
            } else if (incidentSnap.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            List<Incident> incidents = incidentSnap.data;
            return _buildListView(incidents);
          },
        ),
        onRefresh: () {
          return onRefresh();
        },
      ),
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
