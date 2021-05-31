import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final bool transparent;
  const Loading({Key key, this.transparent = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: this.transparent ? Colors.transparent : Constants.lightBG,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
