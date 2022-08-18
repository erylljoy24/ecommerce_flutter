import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/models/event.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../view_profile.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'event_participant.dart';

class EventView extends StatefulWidget {
  final Event event;
  final VoidCallback refreshCallback;

  EventView(this.event, this.refreshCallback);
  @override
  State<StatefulWidget> createState() => new _EventViewState();
}

class _EventViewState extends State<EventView> {
  List<bool> _selectedParticipantType = [];
  List<bool> _selectedCategories = [];

  String _participantType = User.BUYER_TYPE;

  Event? _event;

  bool _isLoading = false;
  double progress = 0.2;

  String? _amountErrorMessage;

  final spinkit = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven ? Colors.red : Colors.green,
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();

    print('view_event.dart');

    setState(() {
      _event = widget.event;
      _selectedParticipantType.add(true);
      _selectedParticipantType.add(false);

      _selectedCategories.add(false);
      _selectedCategories.add(false);
      _selectedCategories.add(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  void modalJoin(BuildContext context, Event? event) {
    double amount = 0.0;
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          final amountController =
              TextEditingController(text: amount.toString());
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: 350,
                padding: EdgeInsets.all(20.0),
                //color: Colors.grey[100],
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Text('Participant Type'),
                          Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [],
                              )),
                          Spacer(),
                          new GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.close)),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 70.0,
                            height: 25.0,
                            child: new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(3.0)),
                                  primary: _selectedParticipantType[0]
                                      ? Colors.green[700]
                                      : Colors.grey[200],
                                ),
                                child: new Text('Buyer',
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        color: _selectedParticipantType[0]
                                            ? Colors.white
                                            : Colors.black)),
                                onPressed: () {
                                  print('set');
                                  setModalState(() {
                                    _participantType = User.BUYER_TYPE;
                                    _selectedParticipantType[0] = true;
                                    _selectedParticipantType[1] = false;
                                  });
                                }),
                          ),
                          Padding(padding: EdgeInsets.only(right: 10)),
                          SizedBox(
                            width: 70.0,
                            height: 25.0,
                            child: new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(3.0)),
                                  primary: _selectedParticipantType[1]
                                      ? Colors.green[700]
                                      : Colors.grey[200],
                                ),
                                child: new Text('Seller',
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        color: _selectedParticipantType[1]
                                            ? Colors.white
                                            : Colors.black)),
                                onPressed: () {
                                  print('set');
                                  setModalState(() {
                                    _participantType = User.SELLER_TYPE;
                                    _selectedParticipantType[1] = true;
                                    _selectedParticipantType[0] = false;
                                  });
                                }),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 16)),
                      Text('Category'),
                      Padding(padding: EdgeInsets.only(bottom: 16)),
                      Wrap(
                        direction: Axis.horizontal,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: 100.0,
                            height: 25.0,
                            child: new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(3.0)),
                                  primary: _selectedCategories[0]
                                      ? Colors.green[700]
                                      : Colors.grey[200],
                                ),
                                child: new Text('Vegetables',
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        color: _selectedCategories[0]
                                            ? Colors.white
                                            : Colors.black)),
                                onPressed: () {
                                  setModalState(() {
                                    _selectedCategories[0] =
                                        !_selectedCategories[0];
                                  });
                                }),
                          ),
                          SizedBox(
                            width: 70.0,
                            height: 25.0,
                            child: new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(3.0)),
                                  primary: _selectedCategories[1]
                                      ? Colors.green[700]
                                      : Colors.grey[200],
                                ),
                                child: new Text('Fruits',
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        color: _selectedCategories[1]
                                            ? Colors.white
                                            : Colors.black)),
                                onPressed: () {
                                  setModalState(() {
                                    _selectedCategories[1] =
                                        !_selectedCategories[1];
                                  });
                                }),
                          ),
                          SizedBox(
                            width: 100.0,
                            height: 25.0,
                            child: new ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(3.0)),
                                  primary: _selectedCategories[2]
                                      ? Colors.green[700]
                                      : Colors.grey[200],
                                ),
                                child: new Text('Condiments',
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        color: _selectedCategories[2]
                                            ? Colors.white
                                            : Colors.black)),
                                onPressed: () {
                                  setModalState(() {
                                    _selectedCategories[2] =
                                        !_selectedCategories[2];
                                  });
                                }),
                          ),
                        ],
                      ),
                      Spacer(),
                      Text('Amount'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5.0, 10, 0.0),
                        child: new TextFormField(
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            ThousandsFormatter(allowFraction: true)
                          ],
                          autofocus: false,
                          controller: amountController,
                          decoration: new InputDecoration(
                            errorText: _amountErrorMessage,
                            //hintText: '1000',
                            // labelText: 'PROCEDURE',
                            labelStyle: new TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.0),
                              borderSide: BorderSide(
                                color: Colors.green[700]!,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: button_beige_text_color),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      SafeArea(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 150.0,
                            height: 40.0,
                            child: new ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                //elevation: 5.0,
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    side: BorderSide(color: Colors.red[500]!)),
                                primary: Colors.white,
                              ),
                              child: new Text('Cancel',
                                  style: new TextStyle(
                                      fontSize: 12.0, color: Colors.red[500])),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          SizedBox(
                            width: 150.0,
                            height: 40.0,
                            child: _isLoading
                                ? SpinKitThreeBounce(
                                    color: Colors.green,
                                    size: 20,
                                  )
                                : new ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      //elevation: 5.0,
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(5.0)),
                                      primary: Colors.green[700],
                                    ),
                                    child: new Text('Confirm',
                                        style: new TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white)),
                                    onPressed: () {
                                      print('processing...');
                                      setModalState(() {
                                        _isLoading = true;
                                        _amountErrorMessage = null;
                                      });

                                      print(amountController.text);

                                      if (amountController.text == '0' ||
                                          amountController.text == '0.0' ||
                                          amountController.text == '') {
                                        setModalState(() {
                                          _isLoading = false;
                                          _amountErrorMessage =
                                              'Invalid Amount';
                                        });

                                        return;
                                      }

                                      joinEvent(
                                              _event!.id!,
                                              _participantType,
                                              double.parse(amountController.text
                                                  .replaceAll(',', '')))
                                          .then((map) {
                                        print(map['message']);
                                        setModalState(() {
                                          _isLoading = false;
                                          if (map['error'] != null) {
                                            _amountErrorMessage =
                                                map['message'];
                                            //return;
                                          } else {
                                            Navigator.pop(
                                                context, {"result": "success"});
                                          }
                                          //_amountErrorMessage = 'Error';
                                        });
                                      });
                                    },
                                  ),
                          ),
                        ],
                      ))
                    ],
                  ),
                ),
              ));
        });
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    print('modal closed');
    // Reload the page
    findEvent(_event!.id).then((map) {
      widget.refreshCallback(); // refresh events list
      setState(() {
        _event = Event.fromMap(map);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<ChangeNotifierUser>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Details',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        leading: popArrow(context),
        bottomOpacity: 0.0,
      ),
      //backgroundColor: Colors.white,
      body: Container(
          color: Colors.grey[100],
          child: ListView(
            children: [
              Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Text('Event')),
                    line(),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(_event!.name!),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16, top: 15),
                          child: Icon(
                            Icons.pin_drop,
                            color: Colors.blue[700],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 2, top: 15),
                          child: SizedBox(
                            width: 250,
                            child: Text(
                              _event!.address!,
                              style: TextStyle(
                                  color: Colors.blue[700], fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 15)),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 16, top: 10),
                        child: Text('Organizer')),
                    line(),
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewProfile(user: _event!.user)));
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                backgroundImage: CachedNetworkImageProvider(
                                    _event!.imageUrl!),
                                radius: 20,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(_event!.userName!),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 15)),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 16, top: 10),
                        child: Text('Progress')),
                    line(),
                    Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              padding: EdgeInsets.only(left: 16),
                              child: Row(
                                children: [
                                  Image(
                                      height: 50,
                                      width: 50,
                                      image: AssetImage(
                                          'assets/images/quota.jpg')),
                                  Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'P' + _event!.quota!,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            'Quota',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            )),
                        // Show button only if not the creator of event
                        user.getUserId() != _event!.user!.id
                            ? Expanded(
                                flex: 2,
                                child: Container(
                                  decoration:
                                      const BoxDecoration(color: Colors.white),
                                  padding: EdgeInsets.only(right: 16),
                                  child: SizedBox(
                                    width: 100.0,
                                    height: 40.0,
                                    child: new ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          //elevation: 5.0,
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      3.0)),
                                          primary: Colors.green[700],
                                        ),
                                        child: new Text('Join Event',
                                            style: new TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white)),
                                        onPressed: () {
                                          // Allow join if not the creator of event
                                          if (user.getUserId() !=
                                              _event!.user!.id) {
                                            modalJoin(context, _event);
                                          } else {
                                            print('not allowed');
                                          }
                                        }),
                                  ),
                                ))
                            : Container(),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              padding: EdgeInsets.only(left: 16),
                              child: Row(
                                children: [Text('Total Amount')],
                              ),
                            )),
                        Expanded(
                            flex: 1,
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              padding: EdgeInsets.only(right: 16),
                              child: Text(
                                'P' + _event!.totalAmount!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Center(
                        child: new CircularPercentIndicator(
                      radius: 120.0,
                      lineWidth: 17.0,
                      percent: _event!.percentageNumber!,
                      center: new Text(
                        _event!.percentage! + "%",
                        style: TextStyle(fontSize: 20),
                      ),
                      progressColor: Colors.green[800],
                    )),
                    Padding(padding: EdgeInsets.only(bottom: 10)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 15)),
              _event!.participants.length != 0
                  ? Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 16, top: 10),
                                  child: Text('Participants')),
                              Padding(
                                  padding: EdgeInsets.only(right: 16, top: 10),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EventParticipant(
                                                            _event)));
                                          },
                                          child: Text(
                                            'View All',
                                            style: TextStyle(
                                                color: Colors.green[900]),
                                          )),
                                      Icon(
                                        Icons.navigate_next_outlined,
                                        color: Colors.green[700],
                                        size: 12,
                                      )
                                    ],
                                  )),
                            ],
                          ),
                          line(),
                          Container(
                            height: 210,
                            child: ListView(
                              children:
                                  _event!.participants.map((User participant) {
                                return participantTile(participant);
                              }).toList(),
                            ),
                          )
                        ],
                      ),
                    )
                  : Center(child: Text('No Participant yet.')),
            ],
          )),
    );
  }
}
