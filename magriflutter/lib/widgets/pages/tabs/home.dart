import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/OrderController.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/models/banner.dart';
import 'package:magri/models/category.dart';
import 'package:magri/models/changenotifiers/changenotifier_connection.dart';
import 'package:magri/models/order.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/services/base_client.dart';
import 'package:magri/services/location_service.dart';
import 'package:magri/util/colors.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/drop/drop_search.dart';
import 'package:magri/widgets/pages/products/add_product.dart';
import 'package:magri/widgets/pages/seller/seller_orders.dart';
import 'package:magri/widgets/pages/tabs/my_orders.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import '../view_product_list.dart';

// final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    // final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print(notification.toString());
  }
  print('android');
  // Or do other work.
}

class Home extends StatefulWidget {
  final int tabIndex;
  Home({
    required this.tabIndex,
  });
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<Home> {
  // final menuButton = new PopupMenuButton<int>(
  //   onSelected: (int i) {},
  //   itemBuilder: (BuildContext ctx) {},
  //   child: new Icon(
  //     Icons.notifications,
  //   ),
  // );

  final UserController userController = Get.put(UserController());
  final OrderController orderController = Get.put(OrderController());

  bool _isLoading = false;

  final LocalAuthentication auth = LocalAuthentication();

  List<BannerModel> _banners = [];

  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  int _notificationCount = 2;

  bool _isGuest = false;

  int _initialValue = 10;

  TabController? _tabController;
  int _selectedIndex = 0;

  int _current = 0;

  bool _categoriesLoaded = false;

  // List<Widget> _tabList = [
  //   Tab(
  //     child: Text('Market Place'),
  //   ),
  //   Tab(text: 'Vegetables'),
  //   Tab(text: 'Fruits'),
  //   Tab(text: 'Cereals'),
  //   Tab(text: 'Condiments'),
  // ];

  List<Category> _categories = [];

  List<Widget> _tabList = [];

  List<Widget> _tabBarViews = [];

  List<Product> _featuredProducts = [];
  List<Product> _products = [];
  List<Product> _vegetables = [];
  List<Product> _fruits = [];
  List<Product> _cereals = [];
  List<Product> _condiments = [];

  double? _latitude;
  double? _longitude;

  CarouselController buttonCarouselController = CarouselController();

  // Use this so that the tab wont reload again
  // wantKeepAlive = true
  // with AutomaticKeepAliveClientMixin<Home>
  // super.build(context); // need to call super method. on build()
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    fetchCategories().then((categories) {
      setState(() {
        _categories.add(Category(0, 'Market Place', 0));
        _tabList.add(Tab(child: Text('Market Place')));
        _tabBarViews.add(Text('Market place'));
      });
      categories.forEach((item) {
        setState(() {
          _categories.add(item);
          _tabList.add(Tab(text: item.name));
          // _tabBarViews.add(productContent());
        });
      });

      _tabController = TabController(length: _tabList.length, vsync: this);

      _tabController!.addListener(() {
        setState(() {
          _selectedIndex = _tabController!.index;
        });
        print("Selected Index: " + _tabController!.index.toString());
      });

      BaseClient().get('/banners').then((dataItems) {
        setState(() {
          _banners.clear();
          if (dataItems != null) {
            dataItems.forEach((item) {
              _banners.add(BannerModel.fromMap(item));

              print(BannerModel.fromMap(item).imageUrl);
            });
          }

          _categoriesLoaded = true;
        });
      });
    });

    // print('xxx' + widget.tabIndex.toString());

    fetch();
    // Get the location first then fetch the products
    _determinePosition().then((value) {
      fetch();
    });

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     //_showItemDialog(message);
    //   },
    //   onBackgroundMessage: myBackgroundMessageHandler,
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //     //_navigateToItemDetail(message);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //     //_navigateToItemDetail(message);
    //   },
    // );
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   setState(() {
    //     //_homeScreenText = "Push Messaging token: $token";
    //   });
    //   print("Push Messaging token: $token");
    // });

    // _firebaseMessaging.subscribeToTopic('topic');

    print('home');
    _checkBiometrics();
    _getAvailableBiometrics();
    _authenticate();

    //query();
    //createCollection();
    //createDocument();
    //deleteDocument();
    //createUser();

    // Get all orders
    if (userController.user!.type == User.SELLER_TYPE) {
      print('getting orders...');
      orderController.getOrders();
    }
  }

  Widget productContent() {
    return Text(_vegetables.length.toString());
  }

  void fetchCat() async {
    await fetchCategories().then((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  void setTabs() {
    //
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<bool> _determinePosition() async {
    var target;
    try {
      target = await determinePosition();
    } catch (e) {
      target = false;
    }

    if (!mounted) {
      return false;
    }

    setState(() {
      if (target != false) {
        // Set current position of the app user

        _latitude = target.latitude;
        _longitude = target.longitude;

        // Set the user latitude and longitude
        Provider.of<ChangeNotifierUser>(context, listen: false)
            .setLatLang(target);

        print('My latitude: ' + target.latitude.toString());
        print('My longitude: ' + target.longitude.toString());
      }
    });

    return true;
  }

  void fetch() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // BaseClient().get('/banners').then((dataItems) {
    //   setState(() {
    //     _banners.clear();
    //     if (dataItems != null) {
    //       dataItems.forEach((item) {
    //         _banners.add(BannerModel.fromMap(item));
    //       });
    //     }
    //   });
    // });
    orderController.getOrders();
    fetchProducts(latitude: _latitude, longitude: _longitude).then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (dataItems != null) {
          _featuredProducts.clear();
          _products.clear();
          _vegetables.clear();
          _fruits.clear();
          _condiments.clear();
          dataItems.forEach((item) {
            _products.add(Product.fromMap(item));
            if (Product.fromMap(item).featured == true) {
              _featuredProducts.add(Product.fromMap(item));
            }
            if (Product.fromMap(item).categoryId == 1) {
              _vegetables.add(Product.fromMap(item));
            }
            if (Product.fromMap(item).categoryId == 2) {
              _fruits.add(Product.fromMap(item));
            }
            if (Product.fromMap(item).categoryId == 3) {
              _condiments.add(Product.fromMap(item));
            }
            if (Product.fromMap(item).categoryId == 4) {
              _cereals.add(Product.fromMap(item));
            }
          });
        }
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    bool? canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      print('canCheckBiometrics:' + canCheckBiometrics.toString());
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType>? availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      print('availableBiometrics:' + availableBiometrics.toString());
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    // print('auth');
    // if (_availableBiometrics == null) {
    //   print('no _availableBiometrics1');
    //   return;
    // }
    // if (_availableBiometrics.length == 0) {
    //   print('no _availableBiometrics2');
    //   return;
    // }
    final SharedPreferences prefs = await _prefs;
    bool? bioAuthorized = await prefs.getBool('bioAuthorized');

    bool? isGuest = await prefs.getBool('isGuest');

    if (isGuest == true) {
      setState(() {
        _isGuest = true;
      });
    }

    if (isGuest == true) {
      return;
    }

    // If finger/face already used
    if (bioAuthorized != null) {
      return;
    }

    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        // biometricOnly: true,
        localizedReason: 'Scan your fingerprint to authenticate',
        // useErrorDialogs: true,
        // stickyAuth: true
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';

    if (message == 'Authorized') {
      // Then we should store token so than we can use it when user wants to login using
      // face id or finger id
      await prefs.setBool('bioAuthorized', true);
    }
    setState(() {
      _authorized = message;
      print('Auth: ' + message);
    });
  }

  void _cancelAuthentication() {
    auth.stopAuthentication();
  }

  Future<void> _refreshProducts() async {
    print('pull');
    fetch();
  }

  Future<void> _refreshDashboard() async {
    print('pull');
    fetch();
  }

  final List<dynamic> startItems = ["1", "2", "3", "4", 1, 2];

  Widget showSliders() {
    return CarouselSlider(
      options: CarouselOptions(
          autoPlay: false,
          height: 150,
          enableInfiniteScroll: false,
          //enlargeCenterPage: true,
          viewportFraction: 1.0,
          //aspectRatio: 5.0,
          //initialPage: 2,
          //onPageChanged: callbackFunction,
          //scrollDirection:Axis.vertical
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
      carouselController: buttonCarouselController,
      items: _banners
          .map((item) => GestureDetector(
              onTap: () {
                print('banner tap');
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                //height: 100,
                decoration: BoxDecoration(
                  // border: Border.all(
                  //     //color: Colors.red[500],
                  //     ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    // image: NetworkImage(item.imageUrl!),
                    image: CachedNetworkImageProvider(item.imageUrl!),
                  ),
                ),
              )))
          .toList(),
    );
  }

  Widget showController() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _banners.map((url) {
        int index = _banners.indexOf(url);
        return Container(
          width: 10.0,
          height: 10.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index ? Colors.green : Colors.white),
        );
      }).toList(),
    );
  }

  Widget showGreenBoxes() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      height: 72,
      //color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          greenBox(
              'Top Seller',
              Icon(
                Icons.verified_outlined,
                color: Colors.white,
              ),
              true,
              'topseller'),
          greenBox(
              'New Items',
              Image.asset(
                'assets/images/new item.png',
                height: 48.0,
                width: 48.0,
                // color: Colors.green,
              ),
              true,
              'mostrecent'),
          // greenBox(
          //     'Add Product',
          //     Icon(Icons.add_circle_outline, color: Colors.white),
          //     true,
          //     '/products/add'),
          greenBox(
              'Magri Drop',
              Image.asset(
                'assets/images/magri drop.png',
                height: 48.0,
                width: 48.0,
                // color: Colors.green,
              ),
              true,
              '/events/index'),
          greenBox(
            'My Orders',
            Icon(Icons.list_alt, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget greenBox(String title, Widget? icon, [bool? isRoute, String? route]) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: GestureDetector(
              onTap: () {
                if (title == 'Magri Drop') {
                  Get.snackbar('Coming soon!', 'Coming soon!');
                  return;
                }
                if (title == 'My Orders') {
                  if (userController.user!.type == User.BUYER_TYPE) {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyOrders()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SellerOrders()));
                  }
                }
                if (isRoute == true) {
                  if (route == 'topseller') {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ViewProductList(listType: 'topseller')));
                  } else if (route == 'mostrecent') {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ViewProductList(listType: 'mostrecent')));
                  } else {
                    if (route == '/products/add') {
                      //
                      _navigateAddProduct(context);
                    } else {
                      Navigator.pushNamed(
                        context,
                        route!,
                      );
                    }
                  }
                }

                print('tap green box');
              },
              child: icon),
        ),
        Padding(padding: EdgeInsets.only(top: 4)),
        Flexible(
            child: GestureDetector(
          onTap: () {
            //Navigator.pop(context);
            print('tap green box');
          },
          child: Text(title, style: ThemeText.greyLabel),
        )),
      ],
    );
  }

  _navigateAddProduct(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProduct()),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // If success then reload the home page data
        fetchProducts().then((dataItems) {
          setState(() {
            _products.clear();
            _vegetables.clear();
            _fruits.clear();
            _condiments.clear();
            _cereals.clear();
            if (dataItems != null) {
              dataItems.forEach((item) {
                _products.add(Product.fromMap(item));
                if (Product.fromMap(item).categoryId == 1) {
                  _vegetables.add(Product.fromMap(item));
                }
                if (Product.fromMap(item).categoryId == 2) {
                  _fruits.add(Product.fromMap(item));
                }
                if (Product.fromMap(item).categoryId == 3) {
                  _condiments.add(Product.fromMap(item));
                }
              });
            }
          });
        });
      }
    }
  }

  Widget showDiscoverViewAll() {
    return Container(
      padding: EdgeInsets.only(left: 5, top: 27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Featured Items',
            style: ThemeText.yellowLabel,
          ),
          // GestureDetector(
          //   child: Text('_'),
          //   onTap: () {
          //     print('tap');
          //     Navigator.of(context).push(MaterialPageRoute(
          //         builder: (context) => Checkout(orderItem: null)));
          //   },
          // ),
          GestureDetector(
              onTap: () {
                print('tap view all');
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ViewProductList(listType: 'featured')));
              },
              child: _featuredProducts.length == 0
                  ? Text('') //  Hide no featured
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              'View All',
                              style: ThemeText.greenLabel,
                            )),
                        Padding(padding: EdgeInsets.only(right: 5)),
                        SvgPicture.asset(
                          'assets/images/home/view all.svg',
                          height: 21.6,
                          width: 21.6,
                          color: Colors.green,
                        )
                      ],
                    ))
        ],
      ),
    );
  }

  Widget showMagriDropViewAll() {
    // return Container();
    return Container(
      padding: EdgeInsets.only(left: 5, top: 27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Magri Drop',
            style: ThemeText.yellowLabel,
          ),
          GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DropSearch()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'View All',
                        style: ThemeText.greenLabel,
                      )),
                  Padding(padding: EdgeInsets.only(right: 5)),
                  SvgPicture.asset(
                    'assets/images/home/view all.svg',
                    height: 21.6,
                    width: 21.6,
                    color: Colors.green,
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget homeTab(currentUser) {
    return RefreshIndicator(
        color: Colors.green[600],
        onRefresh: _refreshProducts,
        child: ListView(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _isLoading
                  ? Center(
                      child: spin(),
                    )
                  : Container(),
              Stack(children: [
                showSliders(),
                Positioned(
                    child: showController(), bottom: 0, right: 0, left: 0),
              ]),
              // showSliders(),
              //   Positioned(
              //       child: showController(), bottom: 0, right: 10, left: 10),

              showGreenBoxes(),
              showDiscoverViewAll(),
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: _isLoading
                    ? Center(
                        child: Text(''),
                      )
                    : Consumer<ChangeNotifierConnection>(
                        builder: (context, connection, child) {
                          if (!connection.isOnline()) {
                            return Container(
                              height: 20,
                              color: Colors.grey[900],
                              child: Center(
                                  child: Text(
                                'Unable to connect',
                                style: TextStyle(color: Colors.white),
                              )),
                            );
                          }

                          return Container();
                        },
                      ),
                //: Container(child: null),
              ),

              //Expanded(child: showProducts('recommended'))
              // showProducts(
              //     'recommended', NeverScrollableScrollPhysics())
              _isLoading
                  ? shim(context, _isLoading)
                  : showProducts(context, currentUser, _featuredProducts,
                      physics: NeverScrollableScrollPhysics(),
                      isLoading: _isLoading)
            ]));
  }

  Widget productsTab(Category category, List<Product> products) {
    var currentUser = context.watch<ChangeNotifierUser>().getUser();
    return RefreshIndicator(
        color: Colors.green[600],
        onRefresh: _refreshProducts,
        child: _isLoading
            ? Center(
                child: spin(),
              )
            : showProducts(context, currentUser, products,
                isLoading: _isLoading));
  }

  Widget buyerHome() {
    var currentUser = context.watch<ChangeNotifierUser>().getUser();
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTop(
        context,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(49),
          child: Material(
              // Set the background color of the tab here
              color: Colors.white,
              //elevation: 1,
              shadowColor: Colors.grey,
              child: Container(
                  margin: EdgeInsets.zero,
                  child: TabBar(
                    indicatorWeight: 5,
                    labelColor: greenColor,
                    // labelStyle: ,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0XFFFECD4D),
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    onTap: (index) {
                      // Should not used it as it only called when tab options are clicked,
                      // not when user swapped
                    },
                    controller: _tabController,
                    tabs: _tabList,
                  ))),
        ),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 10.0),
        child: Stack(children: [
          TabBarView(
            controller: _tabController,
            children: _categories.map((Category category) {
              if (category.name == 'Market Place') {
                return homeTab(currentUser);
              }

              return productsTab(
                  category,
                  _products
                      .where((element) => element.categoryId == category.id)
                      .toList());
            }).toList(),
          ),
          // Positioned(
          //     bottom: 4,
          //     child: SizedBox(
          //       width: MediaQuery.of(context).size.width,
          //       height: 50,
          //       child: Container(
          //           color: const Color(0XFF00A652),
          //           child: Marquee(
          //             style: TextStyle(
          //                 fontWeight: FontWeight.bold, color: Colors.white),
          //             text:
          //                 'Produce SRP: Carrots - Php 80.00/kl | Potatoes - Php 80.00/kl change it via web socket ',
          //           )),
          //     )),
        ]),
      ),
    );
  }

  GestureDetector detector(int index, int number, String title, String route,
          Widget icon, Color color) =>
      GestureDetector(
        onTap: () {
          print('tap');
          if (index == 0) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SellerOrders(
                      tabSelected: STATUS_NEW,
                    )));
          }
          if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SellerOrders(
                      tabSelected: STATUS_CONFIRMED,
                    )));
          }
          if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SellerOrders(
                      tabSelected: STATUS_TODELIVER,
                    )));
          }
          if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SellerOrders(
                      tabSelected: STATUS_CANCELLED,
                    )));
          }
          // if (route == '/waitlist/index') {
          //   // Navigator.pushNamed(context, '/branches/index',
          //   //     arguments: BranchArguments(true));
          //   return;
          // } else if (route == '/appointments/create') {
          //   // Navigator.pushNamed(context, '/barbers/index',
          //   //     arguments: BarberArguments(true));
          //   return;
          // } else {
          //   Navigator.pushNamed(context, route);
          // }
        },
        child: Card(
            margin: EdgeInsets.all(15),
            elevation: 0,
            child: Container(
              color: color,
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      orderController.isLoading
                          ? spin(color: Colors.white)
                          : Text(number.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 35)),
                      IconButton(
                        icon: icon,
                        // icon: Icon(Icons.ac_unit),
                        onPressed: () {
                          // if (route == '/waitlist/index') {
                          //   // Navigator.pushNamed(context, '/branches/index',
                          //   //     arguments: BranchArguments(true));
                          //   return;
                          // } else if (route == '/appointments/create') {
                          //   // Navigator.pushNamed(context, '/barbers/index',
                          //   //     arguments: BarberArguments(true));
                          //   return;
                          // } else {
                          //   Navigator.pushNamed(context, route);
                          // }
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                  ),
                  Row(
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text(
                            title,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.left,
                          ))
                    ],
                  )
                ],
              )),
              //color: Colors.red[50],
            )),
      );

  Widget sellerHome() {
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTop(
        context,
      ),
      body: new Container(
          padding: const EdgeInsets.all(16.0),
          // margin: const EdgeInsets.only(top: 10.0),
          child: RefreshIndicator(
            color: Colors.green[600],
            onRefresh: _refreshProducts,
            child: ListView(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: Text(
                        'Welcome ' +
                            userController.user!.name! +
                            ', today you have:',
                        style: ThemeText.greenLabel)),
                Container(
                  // color: Colors.red,
                    height: 400,
                    // padding: EdgeInsets.fromLTRB(0, 20, 0, 0.0),
                    child: GridView.count(
                      physics: new NeverScrollableScrollPhysics(),
                      // Create a grid with 2 columns. If you change the scrollDirection to
                      // horizontal, this produces 2 rows.
                      crossAxisSpacing: 0.0,
                      crossAxisCount: 2,
                      children: [
                        detector(
                            0,
                            orderController.pending.length,
                            'Pending Orders',
                            '/appointments/create',
                            Image.asset(
                              'assets/images/unconfired.png',
                              height: 103,
                              width: 84,
                            ),
                            const Color(0XFF952FBA)),
                        detector(
                            1,
                            orderController.confirmed.length,
                            'To Process Shipment',
                            '/waitlist/index',
                            Image.asset(
                              'assets/images/to ship items.png',
                              height: 103,
                              width: 84,
                            ),
                            const Color(0XFF326ECE)),
                        detector(
                            2,
                            orderController.delivered.length,
                            'Shipped Orders',
                            '/prices/index',
                            Image.asset(
                              'assets/images/shipped.png',
                              height: 103,
                              width: 84,
                            ),
                            const Color(0XFF00A652)),
                        detector(
                            3,
                            orderController.cancelled.length,
                            'Cancelled Orders',
                            '/branches/index',
                            Icon(
                              Icons.report_outlined,
                              color: Colors.white,
                              size: 35,
                            ),
                            const Color(0XFFB42929)),
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.only(left: 13, right: 13),
                    child: showMagriDropViewAll())
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // need to call super method.

    // Show loading if categories are not yet loaded
    if (_categoriesLoaded == false) {
      return Center(child: spin());
    }

    if (userController.currentUser!.type == 'seller') {
      return sellerHome();
    }

    return buyerHome();
  }
}
