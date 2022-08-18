import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/account/verification.dart';
import 'package:magri/widgets/pages/message/view_chat.dart';
import 'package:magri/widgets/pages/view_profile.dart';

Widget userAccount(BuildContext context, User? user,
    {double width = 42,
    double height = 42,
    Color color = Colors.black,
    Color iconColor = Colors.green,
    bool putActive = true,
    bool isProfile = false,
    bool showVerified = false,
    bool showVerifiedIcon = false,
    bool isUpperCase = false,
    bool putKmAway = false,
    bool navigateProfile = true,
    bool walletName = false,
    messageIcon = false,
    verifyButton = false,
    VoidCallback? callback}) {
  if (user == null) {
    return Container();
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      userImage(context, user,
          width: width,
          height: height,
          color: color,
          putActive: putActive,
          isProfile: isProfile,
          showVerified: showVerified,
          showVerifiedIcon: showVerifiedIcon,
          isUpperCase: isUpperCase,
          navigateProfile: navigateProfile,
          walletName: walletName),
      Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // putActive
              //     ? Text(
              //         seller.lastSeen,
              //         style: TextStyle(color: Colors.black, fontSize: 10),
              //       )
              //     : Container(),
              // message ? messageSellerIcon(_seller) : Container(),
              putKmAway
                  ? Row(
                      children: [
                        Icon(
                          Icons.pin_drop_sharp,
                          color: Colors.blue,
                          size: 18,
                        ),
                        Text('10 km away',
                            style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ],
                    )
                  : Container(),
            ],
          )),
      Row(
        children: [
          messageIcon
              ? messageSellerIcon(context, user, iconColor: iconColor)
              : Container(),
          verifyButton && !user.verified!
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(color: Colors.black),
                    primary: Colors.green[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.green[800]!)),
                  ),
                  onPressed: () {
                    // Respond to button press
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Verification(user)));
                    //Navigator.pushNamed(context, '/account/verify');
                  },
                  child: Text(upperCase('Verify'),
                      style: TextStyle(
                        // fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 13,
                      )),
                )
              : Container(),
          // Icon(
          //   Icons.pin_drop_outlined,
          //   color: Colors.blue,
          // ),
          // Text(
          //   product.distance,
          //   style: TextStyle(color: Colors.blue),
          // ),
        ],
      ),
    ],
  );
}

Widget userImage(BuildContext context, User? user,
    {double radius = 20,
    double width = 42,
    double height = 42,
    Color color = Colors.black,
    bool putActive = false,
    bool isProfile = false,
    bool showVerified = false,
    bool showVerifiedIcon = false,
    bool isUpperCase = false,
    bool navigateProfile = true,
    bool walletName = false,
    bool isRound = false}) {
  if (user == null) {
    return Container();
  }
  return Row(
    children: [
      isRound
          ? CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.image!),
              radius: radius,
            )
          : GestureDetector(
              onTap: () {
                print('tap profile');

                if (navigateProfile) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ViewProfile(user: user)));
                }
              },
              child: Container(
                width: width, // 72 or 42
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  // borderRadius: BorderRadius.only(
                  //     topLeft: Radius.circular(10),
                  //     topRight: Radius.circular(10)),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(user.image!),
                    //image: NetworkImage(product.imageUrl),
                  ),
                ),
              )),
      Padding(
        padding: EdgeInsets.only(left: 10),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                formatName(user, isProfile, isUpperCase),
                style: TextStyle(color: color, fontSize: 15),
              ),
              Padding(padding: EdgeInsets.only(right: 10)),
              showVerifiedIcon && user.verified!
                  ? Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 15,
                    )
                  : Text(''),
            ],
          ),
          Padding(padding: EdgeInsets.only(bottom: 5)),
          // If wallet name
          walletName
              ? Text(
                  'My Wallet',
                  style: TextStyle(color: color, fontSize: 15),
                )
              : Container(),
          putActive
              ? Text(user.lastSeen,
                  style: TextStyle(color: color, fontSize: 12))
              : Container(),
          showVerified
              ? Text(
                  user.verified! ? 'Verified' : 'Not Verified',
                  style: TextStyle(color: Colors.grey),
                )
              : Container()
        ],
      ),
    ],
  );
}

String formatName(User user, bool isProfile, bool isUpperCase) {
  String? name = isProfile ? user.name : 'Seller: ' + user.name!;

  if (isUpperCase) {
    name = upperCase(name!);
  }
  // print(name! + '--');
  return name!;
}

Widget messageSellerIcon(BuildContext context, User user,
    {Color iconColor = Colors.green, radius = 20}) {
  return GestureDetector(
      onTap: () {
        print('tap chat');
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ViewChat(user: user)));
      },
      child: Icon(
        Icons.email_outlined,
        size: 36,
        color: iconColor,
      ));
  // return Icon(
  //   Icons.email_outlined,
  //   size: 36,
  //   color: Colors.green,
  // );
}

// Widget seller(context, {Product product, User seller}) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Row(
//         children: [
//           GestureDetector(
//             onTap: () {
//               print('tap profile');

//               Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => ViewProfile(user: seller)));
//             },
//             child: CircleAvatar(
//               //backgroundColor: Colors.white,
//               // backgroundImage: NetworkImage(_seller.image),
//               backgroundImage: CachedNetworkImageProvider(seller.image),

//               radius: 20,
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(left: 10),
//             child: GestureDetector(
//               onTap: () {
//                 print('tap profile');
//                 Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => ViewProfile(user: seller)));
//               },
//               child: Text(seller.name),
//             ),
//           ),
//         ],
//       ),
//       Row(
//         children: [
//           Icon(
//             Icons.pin_drop_outlined,
//             color: Colors.blue,
//           ),
//           Text(
//             product.distance,
//             style: TextStyle(color: Colors.blue),
//           ),
//         ],
//       ),
//     ],
//   );
// }
