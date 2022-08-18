import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magri/widgets/pages/splash_screens/splash_page_three.dart';

class BuyerOrSellerScreen extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _BuyerOrSellerScreenState();
}

class _BuyerOrSellerScreenState extends State<BuyerOrSellerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Image.asset(
              "assets/images/bg_splash.png",
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
            Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Hero(
                    tag: 'show-logo',
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 90.0, 0.0, 0.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120,
                        width: 300,
                      ),
                    ),
                  ),
                  Text(
                    'MAGRI',
                    style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'Ubuntu',
                      color: Color(0xFF56A937),
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50,),
                  Text(
                    'Continue As',
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Ubuntu',
                        color: Color(0xFFAAAAAA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20,),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                        child: TextButton(
                          onPressed: () {
                            Get.to(SplashPageThree());
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(150.0, 15.0, 150.0, 15.0),
                            backgroundColor: Color(0xFF56A937),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Color(0xFF56A937))
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Buyer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                        child: TextButton(
                          onPressed: () {
                            Get.to(SplashPageThree());
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(150.0, 15.0, 150.0, 15.0),
                            backgroundColor: Color(0xFFFECD4D),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Color(0xFFFECD4D))
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Seller',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}