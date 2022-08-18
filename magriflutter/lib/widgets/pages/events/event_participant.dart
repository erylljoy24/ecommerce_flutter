import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magri/models/event.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import '../view_profile.dart';

class EventParticipant extends StatefulWidget {
  final Event? event;
  EventParticipant(this.event);
  @override
  State<StatefulWidget> createState() => new _EventParticipantState();
}

class _EventParticipantState extends State<EventParticipant> {
  bool _isLoading = false;

  List<User> _participants = [];

  @override
  void initState() {
    super.initState();

    print('event_participant.dart');

    fetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetch() {
    setState(() {
      _isLoading = true;
    });
    fetchEventParticipants(widget.event!.id!).then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (dataItems != null) {
          dataItems.forEach((item) {
            _participants.add(User.fromMap(item));
          });
        }
        _isLoading = false;
      });
    });
  }

  ListTile participantTile(User user) => ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: CachedNetworkImageProvider(user.image!),
          radius: 20,
        ),
        title: Text(user.name!),
        subtitle: Text(user.tags),
        trailing: Icon(Icons.more_horiz),
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewProfile(user: user)));
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: body_color,
          title: Text(
            'Event Participants',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          leading: popArrow(context),
          bottomOpacity: 0.0,
        ),
        backgroundColor: body_color,
        body: new Container(
          child: _isLoading
              ? linearProgress()
              : ListView(
                  children: _participants.map((User participant) {
                    return participantTile(participant);
                  }).toList(),
                ),
        ));
  }
}
