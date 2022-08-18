import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/widgets/pages/help_center.dart';
import 'package:magri/widgets/pages/seller/product_list.dart';
import 'package:magri/widgets/pages/seller/seller_orders.dart';
import 'package:magri/widgets/pages/tabs/my_orders.dart';
import 'package:magri/models/notif.dart';
import 'package:magri/models/user.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/account/account_address.dart';
import 'package:magri/widgets/pages/products/add_product.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:provider/provider.dart';

import 'package:shimmer/shimmer.dart';
import '../my_wallet.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class Account extends StatefulWidget {
  Account({Key? key, this.logoutCallback}) : super(key: key);

  final VoidCallback? logoutCallback;
  @override
  State<StatefulWidget> createState() => new _AccountState();
}

class _AccountState extends State<Account>
    with AutomaticKeepAliveClientMixin<Account> {
  List<Notif> items = [];

  bool _isLoading = false;
  bool? _isVerified = false;
  double progress = 0.2;

  Auth auth = new Auth();

  User? _user;

  final UserController userController = Get.put(UserController());

  // Use this so that the tab wont reload again
  // wantKeepAlive = true
  // with AutomaticKeepAliveClientMixin<Account>
  // super.build(context); // need to call super method. on build()
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    currentFile('account.dart');
    // checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void checkAuth() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   auth.signInToken().then((value) {
  //     print('auth ok');

  //     auth.getUserData().then((userData) {
  //       setState(() {
  //         _user = User.fromMap(userData);
  //         _isVerified = userData['verified'];
  //         _isLoading = false;
  //       });
  //     });
  //   });
  //   print('auth');
  // }

  void deleteStorage() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove('userId');
    await prefs.remove('userDetails');
    //await storage.delete(key: 'token');
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

  void navigateStartSelling() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AddProduct()));
  }

  void navigateWallet() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MyWallet()));
  }

  void navigateAddressBook() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => AccountAddress()));
  }

  void navigateMyOrders() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MyOrders()));
  }

  void navigateHelpCenter() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HelpCenter()));
  }

  // For seller
  void navigateProductList() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ProductList()));
  }

  void navigateSellerOrders() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SellerOrders()));
  }

  void navigateFulfilledOrders() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SellerOrders()));
  }

  void navigateSignOut() {
    deleteStorage();
    widget.logoutCallback!();
    // Navigator.of(context).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'),
    //     arguments: SignOutArguments(true));
  }

  Widget menus(String userType) {
    // print(userType);
    // For seller menu
    if (userType == User.SELLER_TYPE) {
      return ListView(children: <Widget>[
        menuLink('Order Management',
            image: Image.asset(
              'assets/images/order management.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'View Orders',
            callback: navigateSellerOrders),
        // menuLink('Product List',
        //     subtitle: 'All Products', callback: navigateProductList),
        menuLink('My Wallet',
            image: Image.asset(
              'assets/images/my wallet.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'View my wallet',
            callback: navigateWallet),
        // menuLink('Fulfilled Orders',
        //     subtitle: 'Previous Orders', callback: navigateFulfilledOrders),
        menuLink('Help Center',
            image: Image.asset(
              'assets/images/help center.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'View tutorials/Access support',
            callback: navigateHelpCenter),
        menuLink('Sign Out',
            image: Image.asset(
              'assets/images/sign out.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'Log out of your access',
            callback: navigateSignOut),
      ]);
    }

    // For buyer menu
    return ListView(
      children: <Widget>[
        // ListTile(
        //   leading: CircleAvatar(
        //     //backgroundImage: NetworkImage(user.getUserImage()),
        //     backgroundImage: CachedNetworkImageProvider(
        //       user.getUserImage(),
        //     ),
        //     onBackgroundImageError: (_, __) {
        //       setState(() {
        //         //this._isError = true;
        //       });
        //     },
        //     backgroundColor: Colors.transparent,
        //     radius: 25,
        //   ),
        //   title: Align(
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(user.getUserName()),
        //         SizedBox(
        //             height: 30,
        //             child: _isLoading
        //                 ? spin(size: 15)
        //                 : !_isVerified
        //                     ? ElevatedButton(
        //                         style: ElevatedButton.styleFrom(
        //                           textStyle:
        //                               TextStyle(color: Colors.black),
        //                           primary: Colors.white,
        //                           shape: RoundedRectangleBorder(
        //                               borderRadius:
        //                                   BorderRadius.circular(10.0),
        //                               side: BorderSide(
        //                                   color: Colors.green[800])),
        //                         ),
        //                         onPressed: () {
        //                           // Respond to button press
        //                           Navigator.pushNamed(
        //                               context, '/account/verify');
        //                         },
        //                         child: Text('Verify Account',
        //                             style: TextStyle(
        //                               // fontWeight: FontWeight.w500,
        //                               color: Colors.green[800],
        //                               fontSize: 10,
        //                             )),
        //                       )
        //                     : Text(
        //                         'Verified',
        //                         style: TextStyle(
        //                             fontWeight: FontWeight.bold,
        //                             color: Colors.green[700]),
        //                       )),
        //       ],
        //     ),
        //     alignment: Alignment(-1.04, 0),
        //   ),
        //   onTap: () {},
        //   //trailing: Icon(Icons.keyboard_arrow_right),
        // ),
        // _line(10),

        // menuLink('Start Selling',
        //     subtitle: 'Add/Sell Products', callback: navigateStartSelling),
        menuLink('My Wallet',
            image: Image.asset(
              'assets/images/my wallet.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'View my wallet',
            callback: navigateWallet),
        menuLink('Address Book',
            image: Image.asset(
              'assets/images/address book.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'View/Manage my Shipping Address',
            callback: navigateAddressBook),

        menuLink('My Orders',
            image: Image.asset(
              'assets/images/my orders.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'View my orders',
            callback: navigateMyOrders),

        menuLink('Help Center',
            image: Image.asset(
              'assets/images/help center.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'View tutorials/Access support',
            callback: navigateHelpCenter),

        menuLink('Sign Out',
            image: Image.asset(
              'assets/images/sign out.png',
              height: 36,
              width: 36,
            ),
            subtitle: 'Log out of your access',
            callback: navigateSignOut),
        // _menu(
        //     'Start Selling',
        //     Icon(Icons.shopping_bag_sharp, color: Colors.green),
        //     context,
        //     true,
        //     '/products/add'),
        // _line(1),
        // _menu(
        //     'Wallet',
        //     Icon(
        //       Icons.account_balance_wallet_outlined,
        //       color: Colors.red,
        //     ),
        //     context,
        //     true,
        //     '/account/wallet'),
        // _line(1),
        // _menu(
        //     'My Favorites',
        //     Icon(Icons.favorite_border_outlined, color: Colors.red),
        //     context,
        //     true,
        //     'favorites'),
        // _line(1),
        // _menu(
        //     'Recently Viewed',
        //     Icon(Icons.watch_later_outlined, color: Colors.blue),
        //     context,
        //     true,
        //     'recentlyviewed'),
        // _line(1),
        // _menu(
        //     'My Rating',
        //     Icon(
        //       Icons.star_border_outlined,
        //       color: Colors.yellow[800],
        //     ),
        //     context,
        //     true,
        //     '/account/rating'),
        // _line(20),
        // _menu(
        //     'Account Settings',
        //     Icon(
        //       Icons.account_circle,
        //       color: Colors.green,
        //     ),
        //     context,
        //     true,
        //     '/account/settings'),
        // _line(1),
        // _menu(
        //     'Help Centre',
        //     Icon(
        //       Icons.help_center_rounded,
        //       color: Colors.red,
        //     ),
        //     context,
        //     true,
        //     '/account/help'),
        // _line(20),
        // _menu('Logout', Icon(Icons.next_plan), context, false),
        // _line(11),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // need to call super method.
    // var user = context.watch<ChangeNotifierUser>();
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTop(
        context,
        title: userController.user!.type == User.SELLER_TYPE
            ? 'Seller Portal'
            : null,
        showWallet: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: Material(
              // Set the background color of the tab here
              // color: Colors.white,
              //elevation: 1,
              // shadowColor: Colors.grey,
              child: Container(
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 30, 10),
                child: GetBuilder<UserController>(builder: (_) {
                  return userAccount(context, _.currentUser,
                      messageIcon: false,
                      isProfile: true,
                      verifyButton: true,
                      putActive: false,
                      showVerified: true,
                      color: Colors.green[800]!,
                      isUpperCase: true);
                })),
          )),
        ),
      ),
      // appBar: appBarTop(context),
      body: new Center(
        child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: GetBuilder<UserController>(builder: (_) {
                return menus(_.user!.type!);
                // return menus('buyer');
                // return Text(_.user!.type!);
              }),
            )),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     // Get.to(() => Wallet());
      //     userController.setName('cool name');
      //     //
      //   },
      // ),
    );
  }
}
