import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'splash_page_two.dart';

class SplashPageOne extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _SplashPageOneState();
}

class _SplashPageOneState extends State<SplashPageOne> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          showLogo(),
          showText()
        ],
      ),
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'show-logo',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
        child: Image.asset(
          'assets/images/wind_mill.png',
          height: 250,
          width: 300,
        ),
      ),
    );
  }

  Widget showText() {
    return new Hero(
      tag: 'show-text',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
        child: Column(
          children: [
            Text(
              'Helping farmers',
              style: TextStyle(
                fontSize: 25,
                color: Colors.black
              ),
            ),
            SizedBox(height: 20,),
            Padding(
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Consequat quam id tincidunt tortor libero.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                Get.to(SplashPageTwo());
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.fromLTRB(35.0, 15.0, 35.0, 15.0),
                backgroundColor: Color(0xFF56A937),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Color(0xFF56A937))
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}