import 'package:flutter/material.dart';
import 'package:statuscenter/models/incident.dart';

class IncidentsListWidget extends StatefulWidget {
  final Function(String _offset) onRefresh;
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
  Function(String _offset) onRefresh;
  int offset = 1;
  List<Incident> incidents = [];
  ScrollController _scrollController = ScrollController();
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
    _future = this.onRefresh(offset.toString());
    _isRefreshing = false;
    super.initState();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      //double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll == 0) {
        offset++;
        print(offset);
        // setState(() {

        // });
        Future<List<Incident>> moreincdents = this.onRefresh(offset.toString());
        moreincdents.then((value) {
          incidents.addAll(value);
          if (value.isEmpty) {
            print("no more incidents");
            offset--;
          }
        });

        setState(() {});

        print("lasst postion");
      }
    });
  }

  refresh() {
    setState(() {
      offset = 1;
      incidents = [];
    });
    Future newFuture = this.onRefresh('1');
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
            if (offset == 1) {
              incidents.addAll(incidentSnap.data);
            }

            if (incidents == null || incidents.length == 0) {
              return _emptyList(context);
            }
            return _buildListView(incidents, _scrollController);
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

  Widget _buildListView(List<Incident> incidents, _controller) {
    return ListView.builder(
      controller: _controller,
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
