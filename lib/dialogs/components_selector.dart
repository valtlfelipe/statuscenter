import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:statuspageapp/clients/components_client.dart';
import 'package:statuspageapp/models/component.dart';
import 'package:statuspageapp/models/component_status.dart';

class ComponentsSelector extends StatefulWidget {
  final List<Component> components;

  ComponentsSelector({Key key, this.components}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _ComponentsSelectorState(this.components);
}

class _ComponentsSelectorState extends State<ComponentsSelector> {
  List<Component> components;
  Future _componentsBuilder;
  List<AffectedComponentSelector> _data;

  _ComponentsSelectorState(this.components);

  @override
  void initState() {
    _componentsBuilder = getComponents();
    super.initState();
  }

  Future getComponents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Component> data = await new ComponentsClient(
            prefs.getString('apiKey'), prefs.getString('pageId'))
        .getAll();
    setState(() {
      _data = data.map((c) {
        Component alreadySelected = this
            .components
            .firstWhere((comp) => comp.id == c.id, orElse: () => null);
        if (alreadySelected != null) {
          c.status = alreadySelected.status;
          return new AffectedComponentSelector(selected: true, component: c);
        } else {
          return new AffectedComponentSelector(selected: false, component: c);
        }
      }).toList();
    });
    return data;
  }

  _onClose() {
    List<Component> selectedComponents = this
        ._data
        .where((c) => c.selected == true)
        .map((c) => c.component)
        .toList();
    return Navigator.pop(context, selectedComponents);
  }

  Function _onSelectedChanged(AffectedComponentSelector component) {
    int idx = _data.indexOf(component);
    return (bool newValue) {
      setState(() {
        _data[idx].selected = newValue;
      });
    };
  }

  Function _onStatusChanged(AffectedComponentSelector component) {
    int idx = _data.indexOf(component);
    return (String newValue) {
      setState(() {
        _data[idx].component.status = newValue;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.close),
          onPressed: this._onClose,
        ),
        title: Text('Affected components'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(20),
        child: FutureBuilder(
          future: _componentsBuilder,
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
            return SingleChildScrollView(
              child: _componentsListWidget(),
            );
          },
        ),
      ),
    );
  }

  _componentsListWidget() {
    return Column(
      children: this._data.map((AffectedComponentSelector c) {
        return Column(children: [
          Row(
            children: [
              Checkbox(
                  value: c.selected, onChanged: this._onSelectedChanged(c)),
              SizedBox(width: 5),
              Text(c.component.name)
            ],
          ),
          Visibility(
            visible: c.selected,
            child: DropdownButtonFormField(
              items: ComponentStatusList.map((ComponentStatus value) {
                return new DropdownMenuItem(
                  value: value.key,
                  child: new Text(value.name),
                );
              }).toList(),
              isDense: true,
              value: c.component.status,
              onChanged: this._onStatusChanged(c),
            ),
          ),
        ]);
      }).toList(),
    );
  }
}

class AffectedComponentSelector {
  bool selected;
  Component component;

  AffectedComponentSelector({this.selected, this.component});
}
