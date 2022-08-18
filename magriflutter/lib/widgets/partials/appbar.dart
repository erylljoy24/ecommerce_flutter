import 'package:flutter/material.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/my_wallet.dart';
import 'package:flutter_svg/flutter_svg.dart';

AppBar appBarTop(BuildContext context,
        {String? title,
        // bool isMain = true,
        Widget? bottom,
        bool isLogoHidden = false,
        bool isSearch = false,
        bool withBack = false,
        bool showWallet = true,
        Widget? searchBar}) =>
    AppBar(
        // backgroundColor: Colors.white,
        // iconTheme: IconThemeData(
        //   color: Colors.black, //change your color here
        // ),
        backgroundColor: appBarColor,
        bottom: bottom as PreferredSizeWidget?,
        elevation: 7,
        titleSpacing: 0,
        title: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16.0, 30, 16, 16),
          child: isSearch
              ? searchBar
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // withBack ? popArrow(context) : Text(''),
                    isLogoHidden
                        ? withBack
                            ? popArrow(context)
                            : Container(height: 0)
                        : SvgPicture.asset(
                            'assets/images/Magri_Logo.svg',
                            height: 23,
                            width: 85,
                            color: logoColor,
                          ),
                    title != null
                        ? Text(
                            title,
                            style: TextStyle(color: Colors.black),
                          )
                        : showWallet
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MyWallet()));
                                },
                                child: SvgPicture.asset(
                                  'assets/images/my wallet.svg',
                                  height: 26,
                                  width: 29,
                                  color: iconColor,
                                ),
                              )
                            : Container()
                  ],
                ),
        ));

AppBar appBarTopWithBack(BuildContext context,
        {required String title, bool isMain = true, Widget? bottom}) =>
    AppBar(
      backgroundColor: appBarColor,
      bottom: bottom as PreferredSizeWidget?,
      elevation: 7,
      titleSpacing: 0,
      leading: popArrow(context),
      title: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(0.0, 30, 16, 25),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // .end for right side or .center
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
