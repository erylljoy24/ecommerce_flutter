import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:magri/models/category.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/models/user_rating.dart';
import 'package:magri/widgets/modals/rate_seller_modal.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/partial_search.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/colors.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/Constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:magri/widgets/partials/account.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'message/view_chat.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class Debouncer {
  final int? milliseconds;
  VoidCallback? action;
  Timer? _timer;
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds!), action);
  }
}

class ViewProfile extends StatefulWidget {
  final User? user;
  ViewProfile({
    required this.user,
  });
  @override
  State<StatefulWidget> createState() => new _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile>
    with SingleTickerProviderStateMixin {
  final _debouncer = Debouncer(milliseconds: 500);
  String? _search;

  bool _isLoading = false;
  bool _followIsLoading = false;

  List<Category> _categories = [];

  List<Product> _products = [];
  List<Product> _featuredProducts = [];

  List<UserRating> _userRatings = [];

  User? _seller;

  int _itemCount = 10;

  CarouselController buttonCarouselController = CarouselController();

  TabController? _tabController;

  List<Widget> _tabList = [
    // Tab(text: 'Recommended', icon: Icon(Icons.card_travel)),
    Tab(
      child: Text('Featured'),
    ),
    Tab(text: 'Products'),
    Tab(text: 'Categories'),
    Tab(text: 'Reviews'),
  ];

  int _selectedIndex = 0;

  final searchController = TextEditingController();

  bool _isShowResult = false;

  String _q = '';

  bool _isFollowing = false;
  String _followLabel = 'Follow';

  bool _showfollowMessage = false;

  final spinkit = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven ? Colors.red : Colors.green,
        ),
      );
    },
  );

  // Future<List<dynamic>> fetchProducts() async {
  //   final SharedPreferences prefs = await _prefs;

  //   setState(() {
  //     //_isLoading = true;
  //   });

  //   print(Constants.getProducts);

  //   try {
  //     var bearerToken = 'Bearer ' + token;
  //     var result = await http.get(Constants.getProducts,
  //         headers: <String, String>{
  //           'Accept': 'application/json',
  //           'Authorization': bearerToken
  //         });

  //     Map<String, dynamic> map = json.decode(result.body);
  //     print(Constants.getProducts + result.statusCode.toString());

  //     setState(() {
  //       //_isLoading = false;
  //     });
  //     if (result.statusCode == 200) {
  //       return map['data'];
  //     }
  //   } catch (e) {
  //     print('Error: ' + e.toString());
  //     setState(() {
  //       //_isLoading = false;
  //     });
  //   }

  //   return null;
  // }

  Future follow(String id) async {
    final SharedPreferences prefs = await _prefs;
    String? token = await prefs.getString('token');

    setState(() {
      _followIsLoading = true;
    });

    try {
      final url = Uri.parse(Constants.base + '/users/' + id + '/follow');
      var bearerToken = 'Bearer ' + token.toString();
      var result = await http.post(url, headers: <String, String>{
        'Accept': 'application/json',
        'Authorization': bearerToken
      });

      Map<String, dynamic>? map = json.decode(result.body);
      print(result.statusCode.toString());

      if (result.statusCode == 200) {
        print(map!['is_following'].toString());

        setState(() {
          _followIsLoading = false;
          if (map['is_following']) {
            _isFollowing = true;
            _followLabel = 'Following';
          } else {
            _isFollowing = false;
            _followLabel = 'Follow';
          }
        });
        //return map['data'];
        print('done');
      }
    } catch (e) {
      print('Error: ' + e.toString());
      setState(() {
        _followIsLoading = false;
      });
    }

    setState(() {
      _followIsLoading = false;
    });

    return null;
  }

  Future fetchProfile(String id) async {
    final SharedPreferences prefs = await _prefs;
    String? token = await prefs.getString('token');

    String? userId = await prefs.getString('userId');

    // If not the same as the current user then show follow and message
    if (id != userId) {
      setState(() {
        _showfollowMessage = true;
      });
    }

    // print(userId);

    try {
      final url = Uri.parse(Constants.base + '/users/' + id + '&q=' + _q);
      print(url.path);
      var bearerToken = 'Bearer ' + token.toString();
      var result = await http.get(url, headers: <String, String>{
        'Accept': 'application/json',
        'Authorization': bearerToken
      });

      Map<String, dynamic>? map = json.decode(result.body);
      // print(Constants.base +
      //     '/users/' +
      //     id +
      //     ' status:' +
      //     result.statusCode.toString());

      if (result.statusCode == 200) {
        return map!['data'];
      }
    } catch (e) {
      print('Error: ' + e.toString());
      //setState(() {});
    }

    return null;
  }

  void _setSearchValue(String q) {
    _q = q;

    print('callback:' + q);

    print(_q);
    fetchProfile(widget.user!.id!).then((seller) {
      //print(seller['products']);
      // seller['email'];
      setState(() {
        _featuredProducts.clear();
        _products.clear();

        if (seller != null) {
          seller['products'].forEach((item) {
            _products.add(Product.fromMap(item));
            if (Product.fromMap(item).featured == true) {
              _featuredProducts.add(Product.fromMap(item));
            }
          });
        }
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabList.length, vsync: this);

    _tabController!.addListener(() {
      setState(() {
        _selectedIndex = _tabController!.index;
      });
      print("Selected Index: " + _tabController!.index.toString());

      // fetch(_tabController.index + 1);
    });

    setState(() {
      _isLoading = true;
    });

    setState(() {
      _seller = widget.user;
      // print(_seller!.reviews);
    });

    // print('widget: ' + widget.user!.id!);

    fetchProfile(widget.user!.id!).then((seller) {
      // print('seller' + seller.toString());
      // seller['email'];
      setState(() {
        if (seller['is_following']) {
          _isFollowing = true;
          _followLabel = 'Following';
        } else {
          _followLabel = 'Follow';
        }
        if (seller != null) {
          seller['categories'].forEach((item) {
            _categories.add(Category.fromMap(item));
          });

          seller['products'].forEach((item) {
            _products.add(Product.fromMap(item));
            if (Product.fromMap(item).featured == true) {
              _featuredProducts.add(Product.fromMap(item));
            }
          });

          seller['user_ratings'].forEach((item) {
            _userRatings.add(UserRating.fromMap(item));
          });
        }
        _isLoading = false;
      });
    });

    // fetchProducts().then((dataItems) {
    //   setState(() {
    //     if (dataItems != null) {
    //       dataItems.forEach((item) {
    //         _products.add(Product.fromMap(item));
    //       });
    //     }
    //   });
    // });

    //searchController.addListener(_setSearchValue); // init

    print('view_profile.dart');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget showSearchInput() {
    return SizedBox(
      width: 250.0,
      height: 50.0,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0.0),
          child: PartialSearch(
            placeholder: 'Search',
            callbackSubmitted: _setSearchValue,
          )),
    );
  }

  Widget showFollowMessage() {
    if (_showfollowMessage == false) {
      return Container();
    }
    return Padding(
        padding: EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //spinkit,
            // SpinKitDoubleBounce(
            //   color: Colors.green,
            //   size: 30,
            // ),
            // SpinKitThreeBounce(
            //   color: Colors.green,
            //   size: 20,
            // ),
            SizedBox(
              width: 90.0,
              height: 25.0,
              child: _followIsLoading
                  ? SpinKitThreeBounce(
                      color: Colors.green,
                      size: 20,
                    )
                  : new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //elevation: 5.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            side: BorderSide(color: Colors.green)),
                        primary: _isFollowing
                            ? Colors.green[700]
                            : Colors.white, // can be white if not following
                      ),
                      onPressed: () {
                        print('tap follow');
                        follow(widget.user!.id!);
                      },
                      child: new Text(_followLabel,
                          style: new TextStyle(
                              fontSize: 12.0,
                              color:
                                  _isFollowing ? Colors.white : Colors.green)),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: SizedBox(
                  width: 90.0,
                  height: 25.0,
                  child: new ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      //elevation: 5.0,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0),
                          side: BorderSide(color: Colors.green)),
                      primary: Colors.white,
                    ),
                    child: new Text('Message',
                        style:
                            new TextStyle(fontSize: 12.0, color: Colors.green)),
                    onPressed: () {
                      //
                      print('tap message');
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ViewChat(user: _seller)));
                    },
                  )),
            ),
          ],
        ));
  }

  // Widget profileInfo() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       userAccount(context, _seller, navigateProfile: false),
  //       showFollowMessage(),
  //     ],
  //   );
  // }

  Widget profileReviewsRatings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_seller!.items),
                Text(
                  'Items',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            )),
        Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_seller!.reviews!),
                Text(
                  'Reviews',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            )),
        Padding(
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_seller!.ratings),
                Text(
                  'Ratings',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            )),
      ],
    );
  }

  Widget categoryLink(Category category,
      {int numberItems = 0, int categoryId = 1}) {
    return arrowLinkButton(
      context,
      image: SizedBox(
          width: 44,
          child: Image.asset(
            'assets/images/categories/' + category.image!,
            height: 36,
            width: 36,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                "assets/images/categories/Vegetables.png",
                height: 36,
                width: 36,
              );
            },
          )),
      title: category.name!,
      subtitle: category.numberItems!.toString() + ' items',
      // callback: openPaymentDetails
    );
  }

  void rateSeller(BuildContext? context, User? seller) {
    print('rateSeller');
    rateSellerModal(context!, seller!);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark); // For battery color
    var currentUser = context.watch<ChangeNotifierUser>().getUser();
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTopWithBack(
        context,
        isMain: false,
        title: 'Seller Profile',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(202),
          child: Material(
              // Set the background color of the tab here
              color: Colors.white,
              //elevation: 1,
              shadowColor: Colors.grey,
              child: Container(
                  margin: EdgeInsets.zero,
                  child: Column(children: [
                    Container(
                      color: Colors.grey[700],
                      width: double.infinity,
                      height: 151,
                      child: Column(
                        children: [
                          Padding(
                              padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                              child: userAccount(context, _seller,
                                  width: 56,
                                  height: 56,
                                  putActive: true,
                                  isProfile: true,
                                  showVerifiedIcon: true,
                                  navigateProfile:
                                      false, // no tap if already on profile
                                  color: Colors.white,
                                  iconColor: Colors.white,
                                  messageIcon: true)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(_seller!.items,
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white)),
                                  Text(
                                    'Products',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  )
                                ],
                              ),
                              Container(
                                  height: 50,
                                  child: VerticalDivider(
                                    color: Colors.white,
                                    thickness: 1,
                                  )),
                              Column(
                                children: [
                                  Text(_seller!.reviews!,
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white)),
                                  Text(
                                    'Reviews',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  )
                                ],
                              ),
                              Container(
                                  height: 50,
                                  child: VerticalDivider(
                                    color: Colors.white,
                                    thickness: 1,
                                  )),
                              Column(
                                children: [
                                  Text(_seller!.ratings,
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white)),
                                  Text(
                                    'Rating',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      indicatorWeight: 5,
                      labelColor: greenColor,
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
                    )
                  ]))),
        ),
      ),
      // appBar: AppBar(
      //   backgroundColor: body_color,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       SizedBox(
      //           width: MediaQuery.of(context).size.width / 1.5,
      //           child: Padding(
      //             padding: EdgeInsets.zero,
      //             child: showSearchInput(),
      //           )),
      //       Padding(
      //         padding: EdgeInsets.only(right: 0),
      //         child: Icon(
      //           Icons.more_horiz,
      //           color: Colors.grey,
      //         ),
      //       ),
      //     ],
      //   ),
      //   // title: Text(
      //   //   'Add Product',
      //   //   style: TextStyle(color: Colors.black),
      //   // ),
      //   elevation: 0,
      //   leading: popArrow(context),
      //   bottomOpacity: 0.0,
      // ),
      body: new Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          // margin: const EdgeInsets.only(top: 10.0),
          child: TabBarView(controller: _tabController, children: [
            _isLoading
                ? shim(context, _isLoading)
                : showProducts(context, currentUser, _featuredProducts,
                    noRecordMessage: 'No featured products.',
                    isLoading: _isLoading),
            _isLoading
                ? shim(context, _isLoading)
                : showProducts(context, currentUser, _products,
                    noRecordMessage: 'No products available.',
                    isLoading: _isLoading),
            Container(
                padding: EdgeInsets.fromLTRB(10, 16, 10, 16),
                child: ListView(
                  children: _categories.map((Category category) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 15),
                      child: categoryLink(category),
                    );
                  }).toList(),
                )),
            ListView(
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 35),
                    child: Container(
                        child: Column(
                      children: [
                        RatingBar.builder(
                          initialRating: double.parse(_seller!.ratings),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          ignoreGestures: true,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            print(rating);
                          },
                        ),
                        Text(_seller!.ratings + ' ' + _seller!.ratingWord!),
                        // Text(_seller!.userRatings[0].ratingMessage!),
                      ],
                    ))),
                // Put reviews here
                //Comments and ratings
                Container(
                    padding: EdgeInsets.fromLTRB(29, 16, 29.0, 0.0),
                    child: GridView.count(
                      childAspectRatio: 2.1, // control the height
                      shrinkWrap: true,
                      physics:
                          new NeverScrollableScrollPhysics(), // NeverScrollableScrollPhysics
                      // Create a grid with 2 columns. If you change the scrollDirection to
                      // horizontal, this produces 2 rows.
                      crossAxisCount: 1,
                      // Generate 100 widgets that display their index in the List.
                      // children: [Text('aaaa'), Text('aaaa')],
                      children: _userRatings.map((UserRating userRating) {
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: userAccount(context, userRating.user,
                                      isProfile: true,
                                      putActive: false,
                                      messageIcon: false)),
                              Row(
                                children: [
                                  RatingBar.builder(
                                    initialRating: userRating.rating!,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemSize: 15,
                                    onRatingUpdate: (rating) {
                                      // print(rating);
                                    },
                                  ),
                                  Text(userRating.rating!.toString(),
                                      style: ThemeText.yellowLabel15),
                                  Padding(padding: EdgeInsets.only(right: 10)),
                                  Text(
                                    userRating.dateFormat!,
                                  )
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10)),
                              SizedBox(
                                child: Text(userRating.ratingMessage!),
                              ),
                            ],
                          ),
                        );
                        // return ListTile(title: Text('Test'));
                        // return Text(productRating.ratingMessage!);
                      }).toList(),
                    )),
              ],
            ),
          ])

          // Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     // profileInfo(),
          //     // Padding(
          //     //     padding: EdgeInsets.only(top: 16),
          //     //     child: profileReviewsRatings()),
          //     // Padding(
          //     //   padding: EdgeInsets.only(top: 16),
          //     //   child: _isLoading ? linearProgress() : Container(),
          //     // ),
          //     Expanded(
          //         child: showProducts(
          //       context,
          //       currentUser,
          //       _products,
          //     ))
          //   ],
          // )
          ),
      // If already rated by the buyer then dont show button
      // Also show only on reviews tab
      floatingActionButton: _seller!.rated!
          ? null
          : _selectedIndex == 3
              ? iconActionButton(
                  context: context,
                  buttonColor: 'green',
                  // icon: Icon(Icons.close),
                  text: 'give rating',
                  seller: _seller,
                  userCallback: rateSeller,
                  isLoading: false,
                  callback: null)
              : null,
    );
  }
}
