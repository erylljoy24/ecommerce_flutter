import 'package:flutter/material.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AccountSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  bool isLoading = false;
  double progress = 0.2;

  CarouselController buttonCarouselController = CarouselController();

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
        appBar: AppBar(
          backgroundColor: body_color,
          title: Text(
            'Account Settings',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          leading: popArrow(context),
          bottomOpacity: 0.0,
        ),
        backgroundColor: body_color,
        body: Center(
          child: Text('Under development. UI needed.'),
        ));
  }
}
