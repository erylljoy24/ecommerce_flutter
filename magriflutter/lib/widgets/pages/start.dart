import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:magri/util/colors.dart';

class Start extends StatefulWidget {
  Start({this.startCallback});
  final VoidCallback? startCallback;

  @override
  State<StatefulWidget> createState() => new _StartState();
}

class _StartState extends State<Start> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int _current = 0;

  @override
  void initState() {
    super.initState();
    print('start.dart');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void goToApp() {
    widget.startCallback!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
          child: Padding(
        padding: EdgeInsets.only(top: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(child: showStartItems()),
            showController()
          ],
        ),
      )),
    );
  }

  final List<dynamic> startItems = [
    {"name": "SELL", "image": "logo.png", "text": " text here"},
    {"name": "BUY", "image": "logo.png", "text": " text here"},
    {"name": "EARN", "image": "logo.png", "text": " text here"}
  ];

  Widget showStartItems() {
    return CarouselSlider(
      options: CarouselOptions(
          autoPlay: false,
          height: 500,
          enableInfiniteScroll: false,
          //enlargeCenterPage: true,
          viewportFraction: 0.90,
          aspectRatio: 3.0,
          enlargeCenterPage: true,
          //initialPage: 2,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
      items: startItems
          .map((item) => Container(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(children: [
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                item['name'],
                              ),
                              Image.asset(
                                'assets/images/' + item['image'],
                                height: 150,
                                width: 150,
                              ),
                              Text(
                                item['text'],
                                style: TextStyle(
                                  // fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget showController() {
    if (_current == 2) {
      return Container(
        padding: EdgeInsets.only(top: 15),
        child: new GestureDetector(
            onTap: () {
              goToApp();
            },
            child: new Text(
              "GET STARTED",
              style: new TextStyle(
                  color: Colors.green,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold),
            )),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: startItems.map((url) {
        int index = startItems.indexOf(url);
        return Container(
          width: 10.0,
          height: 10.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _current == index ? Colors.green : Color.fromRGBO(0, 0, 0, 0.4),
          ),
        );
      }).toList(),
    );
  }
}
