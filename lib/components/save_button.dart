import 'package:flutter/material.dart';
import 'package:statuscenter/utils/color.dart';

class SaveButton extends StatelessWidget {
  final bool isSaving;
  final Function onPressed;
  final String label;
  const SaveButton(
      {Key key, this.onPressed, this.isSaving = false, this.label = 'Create'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text(
          isSaving ? 'Saving...' : this.label,
          style: TextStyle(color: Colors.white),
        ),
        onPressed: this.isSaving ? null : this.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ACCENT_COLOR,
        ),
      ),
    );
  }
}
