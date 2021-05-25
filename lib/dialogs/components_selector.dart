import 'package:flutter/material.dart';
import 'package:statuscenter/clients/components_client.dart';
import 'package:statuscenter/models/auth_data.dart';
import 'package:statuscenter/models/component.dart';
import 'package:statuscenter/models/component_status.dart';
import 'package:statuscenter/services/auth_service.dart';

class ComponentsSelectorDialog extends StatefulWidget {
  final List<Component> components;
  final bool allowStatusChange;

  ComponentsSelectorDialog({Key key, this.components, this.allowStatusChange})
      : super(key: key);

  @override
  _ComponentsSelectorDialogState createState() =>
      new _ComponentsSelectorDialogState();
}

class _ComponentsSelectorDialogState extends State<ComponentsSelectorDialog> {
  Future _componentsBuilder;
  List<AffectedComponentSelector> _data;

  @override
  void initState() {
    _componentsBuilder = getComponents();
    super.initState();
  }

  Future getComponents() async {
    AuthData authData = await AuthService.getData();
    List<Component> data =
        await new ComponentsClient(authData.apiKey, authData.page.id).getAll();
    setState(() {
      _data = data.map((c) {
        Component alreadySelected = widget.components
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
    return WillPopScope(
      onWillPop: () async {
        this._onClose();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: this._onClose,
          ),
          title: Text('Affected components'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: FutureBuilder(
            future: _componentsBuilder,
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
              return SingleChildScrollView(
                child: _componentsListWidget(),
              );
            },
          ),
        ),
      ),
    );
  }

  _componentsListWidget() {
    return Column(
      children: this._data.map((AffectedComponentSelector c) {
        return Column(children: [
          CheckboxListTile(
            title: Text(c.component.name),
            value: c.selected,
            onChanged: this._onSelectedChanged(c),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          Visibility(
            visible: widget.allowStatusChange && c.selected,
            child: Container(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: DropdownButtonFormField(
                items: ComponentStatusList.map((ComponentStatus value) {
                  return new DropdownMenuItem(
                    value: value.key,
                    child: Text(value.name),
                  );
                }).toList(),
                isDense: true,
                value: c.component.status,
                onChanged: this._onStatusChanged(c),
              ),
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
