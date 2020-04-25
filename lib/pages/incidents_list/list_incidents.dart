import 'package:flutter/material.dart';
import 'package:statuscenter/models/incident.dart';

class IncidentsListWidget extends StatefulWidget {
  final Function onRefresh;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final IncidentsListWidgetController controller;

  IncidentsListWidget({
    this.controller,
    this.onRefresh,
    this.scaffoldKey,
  });

  @override
  State<StatefulWidget> createState() => new _IncidentsListWidget(
      this.controller, this.onRefresh, this.scaffoldKey);
}

class IncidentsListWidgetController {
  void Function() refresh;
}

class _IncidentsListWidget extends State<IncidentsListWidget> {
  Future _future;
  bool _isRefreshing;
  Function onRefresh;
  GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      new GlobalKey<RefreshIndicatorState>();

  _IncidentsListWidget(IncidentsListWidgetController _controller,
      Function onRefresh, GlobalKey scaffoldKey) {
    _controller.refresh = () {
      _refreshKey.currentState.show();
    };
    this.onRefresh = onRefresh;
    this.scaffoldKey = scaffoldKey;
  }

  @override
  void initState() {
    _future = this.onRefresh();
    _isRefreshing = false;
    super.initState();
  }

  refresh() {
    Future newFuture = this.onRefresh();
    setState(() {
      _isRefreshing = true;
      _future = newFuture;
    });
    return newFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: new EdgeInsets.all(20.0),
      child: new RefreshIndicator(
        key: _refreshKey,
        child: FutureBuilder(
          future: _future,
          builder: (context, incidentSnap) {
            if (incidentSnap.hasError) {
              return Center(
                child: Text(
                    'Something wrong with message: ${incidentSnap.error.toString()}'),
              );
            } else if (incidentSnap.connectionState != ConnectionState.done &&
                !_isRefreshing) {
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
          return refresh();
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
                if (error != null) {
                  scaffoldKey.currentState
                      .showSnackBar(SnackBar(content: Text(error.toString())));
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
