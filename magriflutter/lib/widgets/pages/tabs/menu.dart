import 'package:flutter/material.dart';
import 'package:magri/util/helper.dart';

class Menu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
        child: Text('Settings'),
      ),
    );
  }
}
