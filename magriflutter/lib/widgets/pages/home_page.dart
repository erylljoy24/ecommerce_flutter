import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/models/category.dart';
import 'package:magri/models/user.dart';
import 'package:magri/widgets/pages/account/verification.dart';
import 'package:magri/widgets/pages/drop/drop_search.dart';
import 'package:magri/widgets/pages/seller/product_list.dart';
import 'package:magri/widgets/pages/tabs/my_orders.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/widgets/pages/account/account_address.dart';
import 'package:magri/widgets/pages/tabs/home.dart';
import 'package:magri/widgets/pages/tabs/notifications.dart';
import 'package:magri/widgets/pages/tabs/payments.dart';
import 'package:magri/widgets/pages/tabs/menu.dart';
import 'package:magri/widgets/pages/tabs/message.dart';
import 'package:magri/widgets/pages/tabs/account.dart';

import 'package:magri/widgets/pages/tabs/search.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/widgets/pages/my_wallet.dart';
import 'package:magri/widgets/pages/wallet/add_credit_card.dart';
import 'package:magri/widgets/pages/wallet/payment_methods.dart';
import 'package:magri/widgets/pages/wallet/top_method.dart';
import 'package:magri/widgets/pages/wallet/top_up.dart';
import 'package:magri/widgets/partials/paymaya_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'account/take_photo.dart';
import 'account/verify_account.dart';
import 'checkout.dart';
import 'events/events.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth? auth;
  final VoidCallback? logoutCallback;
  final String? userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final UserController userController = Get.put(UserController());

  List<bool> _itemsSelected = [true, false, false, false];
  TabController? _controller;
  int _index = 0;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print('home_page.dart');
    _controller = new TabController(length: 4, vsync: this);

    _controller!.addListener(() {
      print("${_controller!.index}");
    });

    // _items = [];
    // _items.add(new BottomNavigationBarItem(
    //     icon: SvgPicture.asset(
    //       'assets/images/home unselected.svg',
    //       height: 23,
    //       width: 85,
    //       color: _itemsSelected[0] ? logoColor : Colors.grey,
    //     ),
    //     label: 'Home'));

    // _items.add(new BottomNavigationBarItem(
    //     icon: SvgPicture.asset(
    //       'assets/images/search.svg',
    //       height: 23,
    //       width: 85,
    //       color: _itemsSelected[1] ? logoColor : Colors.grey,
    //     ),
    //     label: 'Search'));
    // _items.add(new BottomNavigationBarItem(
    //     // icon: messageNotif(),
    //     icon: SvgPicture.asset(
    //       'assets/images/message unselected.svg',
    //       height: 23,
    //       width: 85,
    //       color: _itemsSelected[2] ? logoColor : Colors.grey,
    //     ),
    //     label: 'Messages'));
    // _items.add(new BottomNavigationBarItem(
    //     icon: SvgPicture.asset(
    //       'assets/images/user.svg',
    //       height: 23,
    //       width: 85,
    //       color: _itemsSelected[3] ? logoColor : Colors.grey,
    //     ),
    //     label: 'Account'));

    // If we want to put title
    // https://developermemos.com/posts/remove-title-bottomnavigation-flutter
    // _items.add(new BottomNavigationBarItem(
    // icon: new Icon(Icons.menu), title: new Text('Menu')));

    //_checkEmailVerification();

    getSecureStorage();
  }

  Widget messageNotif() {
    return Stack(
      children: [
        Icon(
          Icons.message_outlined,
          size: 17,
        ),
        // Enable if there is a unread message
        Positioned(
          child: Container(
            width: 10,
            height: 10,
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red[600], // change to transparent if offline
            ),
          ),
          top: -4,
          right: 0,
        )
      ],
    );
  }

  BottomNavigationBar _botNavBar() => BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/home unselected.svg',
                height: 23,
                width: 85,
                color: _itemsSelected[0] ? logoColor : Colors.grey,
              ),
              // label: 'Home'
              label: ''),
          new BottomNavigationBarItem(
              icon: SvgPicture.asset(
                userController.user!.type == User.BUYER_TYPE
                    ? 'assets/images/search.svg'
                    : 'assets/images/inventory.svg',
                height: 23,
                width: 85,
                color: _itemsSelected[1] ? logoColor : Colors.grey,
              ),
              label: ''
              // label: 'Search'
              ),
          new BottomNavigationBarItem(
              // icon: messageNotif(),
              icon: SvgPicture.asset(
                'assets/images/message unselected.svg',
                height: 23,
                width: 85,
                color: _itemsSelected[2] ? logoColor : Colors.grey,
              ),
              label: ''
              // label: 'Messages'
              ),
          BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/user.svg',
                height: 23,
                width: 85,
                color: _itemsSelected[3] ? logoColor : Colors.grey,
              ),
              label: ''
              // label: 'Account'
              )
        ],
        fixedColor: Colors.green[800],
        currentIndex: _index,

        // backgroundColor: Colors.transparent,
        //backgroundColor: Colors.red,
        //showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        //unselectedItemColor: Colors.teal,
        //unselectedIconTheme: IconThemeData(color: Colors.teal),
        unselectedFontSize: 9,
        selectedFontSize: 10,
        //iconSize: 10,
        elevation: 4,
        onTap: (int item) {
          _index = item;
          setState(() {
            this._index = _index;
            _itemsSelected[0] = false;
            _itemsSelected[1] = false;
            _itemsSelected[2] = false;
            _itemsSelected[3] = false;
            _itemsSelected[_index] = true;
          });

          print('_botNavBar index=' + _index.toString());

          _controller!.animateTo(_index);
        },
      );

  @override
  void dispose() {
    super.dispose();
  }

  logoutCallback() async {
    try {
      // await widget.auth.signOut();
      widget.logoutCallback!();
    } catch (e) {
      print(e);
    }
  }

  getSecureStorage() async {
    //final SharedPreferences prefs = await _prefs;

    //this.signOut();
  }

  Widget bottomNavigationBar() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        //color: Colors.red,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          child: SizedBox(height: 70, child: _botNavBar())),
    );
    // return ClipRRect(
    //     borderRadius: BorderRadius.all(
    //       Radius.circular(20),
    //     ),
    //     child: _botNavBar());

    // return Container(
    //   margin: EdgeInsets.only(left: 16, right: 16),
    //   decoration: BoxDecoration(
    //     color: Colors.red,
    //     borderRadius: BorderRadius.all(Radius.circular(20)),
    //   ),
    //   child: _botNavBar(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new TabBarView(
          controller: _controller,
          physics: NeverScrollableScrollPhysics(), // prevent from swipe
          children: <Widget>[
            // new Checkout(paymentMethod: 'cod'),
            //new PayMayaView(),
            //new Wallet(),
            //new TopUp(),
            //new TopUpMethod(),
            // new Search(),
            // new Account(),

            // new TakePhoto(),
            // new PaymentMethods(),
            // new AccountAddress(),
            // new AddCreditCard(),
            // new MyOrders(),
            // new Verification(),
            // new ProductList(),
            new Home(tabIndex: _index),
            // new DropSearch(),
            //new Search(),
            //new VerifyAccount(),
            //new Events(),
            //new Message(),
            userController.user!.type == User.BUYER_TYPE
                ? new Search()
                : new ProductList(),
            new Message(),

            // new Notifications(),
            // new Payments(),
            //new Appointment(),
            new Account(logoutCallback: logoutCallback)
          ],
        ),
        bottomNavigationBar: _botNavBar()); //  _botNavBar()
  }
}
