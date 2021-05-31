import 'package:flutter/material.dart';
import 'package:statuscenter/clients/status_client.dart';
import 'package:statuscenter/components/loading.dart';
import 'package:statuscenter/components/sidebar_menu.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/models/component.dart';
import 'package:statuscenter/models/status.dart';
import 'package:statuscenter/services/auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthData _authData;
  bool _isLoading = true;
  Status _status;

  @override
  void initState() {
    _isLoading = true;
    _loadData();
    super.initState();
  }

  Future _loadAuthData() async {
    if (this._authData == null) {
      AuthData authData = await AuthService.getUpdatedData();
      setState(() {
        _authData = authData;
      });
    }
  }

  Future _loadStatus() async {
    Status status = await new StatusClient().getStatus();
    setState(() {
      _status = status;
    });
  }

  Future _loadData() async {
    await Future.wait([this._loadAuthData(), this._loadStatus()]);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Center'),
      ),
      drawer: new SidebarMenu(
        authData: this._authData,
        currentPage: '/home',
      ),
      body: Container(
        child: _isLoading
            ? Loading()
            : RefreshIndicator(
                onRefresh: () => _loadData(),
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(20),
                  children: [
                    _mainStatus(),
                    SizedBox(height: 10),
                    _dataCards(),
                    SizedBox(height: 10),
                    _componentsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _mainStatus() {
    return Container(
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          color: _status.getColor(),
          height: 50,
          width: double.infinity,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _status.description,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _countCard({Color color, String title, int value, Function onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            color: color,
            height: 100,
            width: double.infinity,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dataCards() {
    return Row(
      children: [
        _countCard(
          color: Colors.red,
          title: 'Open Incidents',
          value: _status.incidentsCount,
          onTap: () {
            Navigator.pushNamed(context, '/incidents');
          },
        ),
        _countCard(
          color: Colors.blue,
          title: 'Scheduled Maintenances',
          value: _status.scheduledMaintenancesCount,
          onTap: () {
            Navigator.pushNamed(context, '/incidents', arguments: 2);
          },
        ),
      ],
    );
  }

  Widget _componentsList() {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 5);
      },
      itemCount: _status.components.length,
      itemBuilder: (context, index) {
        Component component = _status.components[index];
        return Row(
          children: [
            component.getDisplayIcon(),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                component.name,
                style: Theme.of(context).textTheme.subtitle1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        );
      },
    );
  }
}
