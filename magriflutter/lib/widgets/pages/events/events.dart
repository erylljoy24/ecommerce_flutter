import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/models/event.dart';
import 'package:magri/widgets/partials/partial_search.dart';

import 'package:percent_indicator/percent_indicator.dart';

import 'add_event.dart';
import 'view_event.dart';

class Events extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _EventsState();
}

class _EventsState extends State<Events> {
  List<Event> _events = [];

  bool _isLoading = false;
  double progress = 0.2;
  String? _search;

  @override
  void initState() {
    super.initState();

    print('events.dart');

    setState(() {
      _isLoading = true;
    });

    fetch();

    // setState(() {
    //   _events.add(Event(
    //       '1',
    //       'Juana F Delfin',
    //       'https://i2.wp.com/nofiredrills.com/wp-content/uploads/2016/10/myavatar.png',
    //       '20 mins ago',
    //       'Gulay Express Gulay ExpressGulay Express Gulay Express Gulay',
    //       '80,000.00',
    //       '70,000.00',
    //       'Dito lang sa malapit Dito lang sa malapit  Dito lang sa malapit Dito lang sa malapit Dito lang sa malapitDito lang sa malapitDito lang sa malapit ',
    //       '29',
    //       0.29));
    //   _events.add(Event(
    //       '2',
    //       'Juan Dela Toree',
    //       'https://cdn1.vectorstock.com/i/1000x1000/51/05/male-profile-avatar-with-brown-hair-vector-12055105.jpg',
    //       '30 mins ago',
    //       'Gulay Fest 2021',
    //       '78,000.00',
    //       '60,000.00',
    //       'banda dyan sa ilaya',
    //       '50',
    //       0.50));
    //   _events.add(Event(
    //       '2',
    //       'Juan Del Rio',
    //       'https://cdn1.vectorstock.com/i/1000x1000/51/05/male-profile-avatar-with-brown-hair-vector-12055105.jpg',
    //       '10 mins ago',
    //       'Gulay Fest 2021',
    //       '78,000.00',
    //       '60,000.00',
    //       'banda dyan sa ilaya sa may bulacan',
    //       '0',
    //       0.0));
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetch() {
    fetchEvents().then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (dataItems != null) {
          dataItems.forEach((item) {
            _events.add(Event.fromMap(item));
          });
        }
        _isLoading = false;
      });
    });
  }

  void refetch() {
    setState(() {
      _events.clear();
      fetch();
    });
  }

  void search(String q) {}

  Widget showSearchInput() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.3,
      height: 50.0,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0.0),
          child: PartialSearch(
            placeholder: 'Search',
            //color: Colors.white,
            callbackSubmitted: search,
          )),
    );
  }

  GestureDetector eventTile(Event event) => GestureDetector(
        onTap: () {
          print('tap event');
          //Navigator.pushNamed(context, route);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EventView(event, refetch)));
          // Navigator.pushNamed(
          //   context,
          //   '/events/view',
          //   arguments: EventArguments(event),
          // );
        },
        child: Card(
            margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              //height: 700,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(1)),
              ),
              padding: const EdgeInsets.all(0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      // decoration: const BoxDecoration(color: Colors.red),
                      padding: EdgeInsets.only(left: 16, top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey,
                                //backgroundImage: NetworkImage(event.imageUrl),
                                backgroundImage:
                                    CachedNetworkImageProvider(event.imageUrl!),
                                radius: 20,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(event.userName!),
                                      Text(
                                        event.ago!,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  //Text(event.name),
                                  SizedBox(
                                    width: 240,
                                    child: Text(event.name!),
                                  )
                                ],
                              )),
                          Row(
                            children: [
                              Text('Quota: ',
                                  style: TextStyle(color: Colors.grey)),
                              Text('P' + event.quota!,
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.pin_drop,
                                color: Colors.blue[700],
                              ),
                              SizedBox(
                                width: 230,
                                child: Text(
                                  event.address!,
                                  style: TextStyle(
                                      color: Colors.blue[700], fontSize: 10),
                                ),
                              )

                              // Padding(
                              //     padding: EdgeInsets.only(left: 2),
                              //     child: Column(
                              //       mainAxisAlignment: MainAxisAlignment.start,
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [
                              //         Text('111'),
                              //         Text(
                              //           event.address,
                              //           style: TextStyle(
                              //               color: Colors.blue[700],
                              //               fontSize: 10),
                              //         ),
                              //         //Text('20 mins ago'),
                              //       ],
                              //     )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Container(
                      //decoration: const BoxDecoration(color: Colors.blue),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                              padding: EdgeInsets.only(top: 10, right: 16),
                              child:
                                  Icon(Icons.more_horiz, color: Colors.grey)),
                          Padding(
                              padding: EdgeInsets.only(bottom: 10, right: 16),
                              child: new CircularPercentIndicator(
                                radius: 60.0,
                                lineWidth: 7.0,
                                percent: event.percentageNumber!,
                                center: new Text(event.percentage! + "%"),
                                progressColor: Colors.green[800],
                              ))
                        ],
                      ),
                    ),
                    flex: 1,
                  ),
                ],
              ),
            )),
      );

  _navigateAddEvent(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEvent()),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success then reload the home page data
        setState(() {
          _events.clear();
          fetch();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Events',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          leading: popArrow(context),
          bottomOpacity: 0.0,
        ),
        //backgroundColor: Colors.white,
        body: Container(
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 16),
                      child: showSearchInput(),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16, bottom: 16),
                      child: Icon(Icons.menu),
                    ),
                  ],
                ),
                _isLoading
                    ? linearProgress()
                    : Expanded(
                        child: ListView(
                        itemExtent: 160,
                        children: _events.map((Event event) {
                          return eventTile(event);
                        }).toList(),
                      ))
              ],
            )),
        floatingActionButton: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(
              Icons.add,
              color: Colors.black,
            ),
            backgroundColor: Colors.yellow[800],
            onPressed: () {
              _navigateAddEvent(context);
            }));
  }
}
