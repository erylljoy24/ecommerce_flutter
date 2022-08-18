import 'package:flutter/material.dart';

// Add 0xff on hex
const app_bar_color = const Color(0XFFF7E2DC);
// const body_color = const Color(0XFFFFFFFF);
const body_color = const Color(0XFFFCFCFC);
const button_color = const Color(0XFFD69A82);
const button_beige_text_color = const Color(0XFFD69A82);
const button_white_color = const Color(0XFFFFFFFF);

const lineColor = const Color(0XFFEBEBEB);

const appBarButtonColor = const Color(0XFF888888);
const inputBorderColor = const Color(0XFFE6E6E6);

const textColor = const Color(0XFF888888);

const sentenceTextColor = const Color(0XFFB1B1B1);

const hintTextColor = const Color(0XFF808080);

const primarySwatch = const Color(0XFFD69A82);

const appBarColor = const Color(0XFF56A937);

const logoColor = const Color(0XFF56A937);

const iconColor = const Color(0XFF00A652);

const greenColor = const Color(0XFF00A652);

const redColor = const Color(0XFFFF7648);

const buttonRedColor = const Color(0XFFD81D1D);

const buttonYellowColor = const Color(0XFFFFC222);

const buttonGreenColor = const Color(0XFF00A652);

const yellowColor = const Color(0XFFFFC222);

const yellowLabelColor = const Color(0XFFFEC122);

const yellowLabelRatingColor = const Color(0XFFFECD4D);

const greyColor = const Color(0XFF808080);

//const buttonPrimary = const Color(0xfFFFFFFF);

// https://stackoverflow.com/questions/57531969/declaring-a-styles-file-in-flutter
// ThemeText.yelloLabel
abstract class ThemeText {
  static const TextStyle progressHeader = TextStyle(
      fontFamily: 'Montserrat',
      color: Colors.black,
      fontSize: 40,
      height: 0.5,
      fontWeight: FontWeight.w600);

  static const TextStyle progressBody = TextStyle(
      fontFamily: 'Montserrat',
      color: Colors.white,
      fontSize: 10,
      height: 0.5,
      fontWeight: FontWeight.w400);

  static const TextStyle progressFooter = TextStyle(
      fontFamily: 'Montserrat',
      color: Colors.black,
      fontSize: 20,
      height: 0.5,
      fontWeight: FontWeight.w600);
  static const TextStyle yellowLabel = TextStyle(
    //fontFamily: 'Montserrat',
    color: Color(0XFFFEC122),
    fontSize: 16,
    height: 1.8,
  )
      // fontWeight: FontWeight.w600)
      ;

  static const TextStyle yellowLabel24 = TextStyle(
      //fontFamily: 'Montserrat',
      color: Color(0XFFFEC122),
      fontSize: 24,
      height: 1.8,
      fontWeight: FontWeight.w600);

  static const TextStyle yellowLabel15 = TextStyle(
      //fontFamily: 'Montserrat',
      color: Color(0XFFFEC122),
      fontSize: 15,
      height: 1.8,
      fontWeight: FontWeight.w600);

  static const TextStyle greenLabel = TextStyle(
    //fontFamily: 'Montserrat',
    color: Color(0XFF00A652),
    fontSize: 16,
    height: 1.8,
  );

  static const TextStyle whiteLabel = TextStyle(
      //fontFamily: 'Montserrat',
      color: Color(0XFFFFFFFF),
      fontSize: 16,
      height: 1.8,
      letterSpacing: 0.8);

  static const TextStyle greyLabel = TextStyle(
    //fontFamily: 'Montserrat',
    color: greyColor,
    fontSize: 13,
    height: 1.4,
  );

  static const TextStyle greyUbuntuMedium = TextStyle(
    //fontFamily: 'Montserrat',
    color: greyColor,
    letterSpacing: 0.9,
    fontSize: 18,
    height: 1.8,
  );
}

abstract class ThemeButton {
  static const TextStyle progressHeader = TextStyle(
      fontFamily: 'Montserrat',
      color: Colors.black,
      fontSize: 40,
      height: 0.5,
      fontWeight: FontWeight.w600);
}
