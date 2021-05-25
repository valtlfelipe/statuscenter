import 'package:flutter/material.dart';
import 'package:statuscenter/utils/validate_text_field.dart';

class MessageField extends StatelessWidget {
  final Function onSaved;
  const MessageField({Key key, this.onSaved}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: TextFormField(
        decoration: new InputDecoration(labelText: 'Message'),
        keyboardType: TextInputType.multiline,
        minLines: null,
        maxLines: null,
        expands: true,
        validator: validateTextField,
        onSaved: (String value) {
          this.onSaved(value);
        },
      ),
    );
  }
}
