import 'package:flutter/material.dart';
import 'package:statuscenter/dialogs/components_selector.dart';
import 'package:statuscenter/models/component.dart';

class SelectComponents extends StatelessWidget {
  final List<Component> components;
  final bool allowStatusChange;
  final Function onClose;
  const SelectComponents(
      {Key key, this.components, this.allowStatusChange = true, this.onClose})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: new Text(
              'Select affected components',
              style: new TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final List<Component> result = await Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) {
                    return new ComponentsSelectorDialog(
                      components: this.components,
                      allowStatusChange: this.allowStatusChange,
                    );
                  },
                  fullscreenDialog: true,
                ),
              );
              this.onClose(result);
            },
          ),
        ),
        Text(
          '${this.components.length} components affected',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }
}
