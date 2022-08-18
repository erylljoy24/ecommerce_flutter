import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';

class HelpCenter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget menuLink(String name,
      {Widget? image, String subtitle = '', VoidCallback? callback}) {
    return Padding(
        padding: EdgeInsets.fromLTRB(25, 0, 25, 15),
        child: arrowLinkButton(context,
            image: SizedBox(
                width: 44,
                child: image == null
                    ? SvgPicture.asset(
                        'assets/images/cabbage.svg',
                        height: 36,
                        width: 36,
                        color: Colors.green,
                      )
                    : image),
            title: name,
            subtitle: subtitle,
            callback: callback));
  }

  void navigateChatSupport() {
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => AccountAddress()));
  }

  void navigateTutorials() {
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => MyOrders()));
  }

  void navigateFaq() {
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => HelpCenter()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarTopWithBack(context, isMain: false, title: 'Help Center'),
        backgroundColor: body_color,
        body: new Center(
          child: Container(
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: ListView(
                    children: <Widget>[
                      menuLink('Chat Support',
                          image: Image.asset(
                            'assets/images/chat support.png',
                            height: 36,
                            width: 36,
                          ),
                          subtitle: 'Chat with Magri (coming soon...)',
                          callback: navigateChatSupport),
                      menuLink('Tutorials',
                          image: Image.asset(
                            'assets/images/tutorials.png',
                            height: 36,
                            width: 36,
                          ),
                          subtitle: 'Know more about Magri (coming soon...)',
                          callback: navigateTutorials),
                      menuLink('FAQs',
                          image: Image.asset(
                            'assets/images/faqs.png',
                            height: 36,
                            width: 36,
                          ),
                          subtitle: 'Know more about Magri (coming soon...)',
                          callback: navigateFaq),
                    ],
                  ))),
        ));
  }
}
