import 'package:flutter/material.dart';
import 'package:magri/Constants.dart' as Constants;
import 'package:magri/util/helper.dart';
import 'package:magri/models/notif.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Notifications extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Notif> items = [];

  bool isLoading = false;
  double progress = 0.2;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        progress = 0.6;
      });
    });

    setState(() {
      isLoading = true;
    });

    // Fetch items from API. We do it only if we have internet connections
  }

  @override
  void dispose() {
    super.dispose();
  }

  ListTile _tile(int? id, String? userId, String text, String shortText,
          String ago, BuildContext context) =>
      ListTile(
        title: Text(shortText,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            )),
        onTap: () {},
        subtitle: Text(text),
        trailing: Text(ago), // trailing is like right, leading is like left
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: isLoading
              ? CircularProgressIndicator(value: progress)
              : ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                      ),
                  itemCount: items.length,
                  padding: const EdgeInsets.all(15.0),
                  itemBuilder: (context, index) {
                    return _tile(
                        items[index].id,
                        items[index].userId,
                        '${items[index].text}',
                        items[index].shortText!,
                        items[index].ago!,
                        context);
                  })),
    );
  }
}
