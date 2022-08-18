import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/models/product_rating.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class ViewProduct extends StatefulWidget {
  final Product product;
  ViewProduct(this.product);
  @override
  State<StatefulWidget> createState() => new _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  bool isLoading = false;
  double progress = 0.2;

  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;

  CarouselController buttonCarouselController = CarouselController();

  int _current = 0;

  Color? _favoriteColor = Colors.grey;

  List<String> _images = [];

  Product? _product;

  User? _seller;

  bool _showBuyNow = false;

  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();

    _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length));

    getUser();

    setState(() {
      _product = widget.product;
      _product!.qty = 1;
      _images = _product!.images;
      _seller = _product!.user;
    });

    // Store to recently viewed
    view(_product);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUser() async {
    final SharedPreferences prefs = await _prefs;

    String? _currentUserId = await prefs.getString('userId');

    setState(() {
      _currentUserId = _currentUserId;
    });
  }

  void view(Product? product) async {
    addViewed(product);
  }

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  Widget showSliders() {
    return CarouselSlider(
      options: CarouselOptions(
          autoPlay: false,
          height: 250,
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
            print('onPageChanged' + index.toString());
          }),
      carouselController: buttonCarouselController,
      items: _images
          .map((image) => Container(
                width: MediaQuery.of(context).size.width,
                //height: 100,
                decoration: BoxDecoration(
                  // border: Border.all(
                  //     //color: Colors.red[500],
                  //     ),
                  //borderRadius: BorderRadius.all(Radius.circular(15)),
                  image: DecorationImage(
                    // fit: BoxFit.fill,
                    fit: BoxFit.fitWidth,
                    //image: NetworkImage(image),
                    image: CachedNetworkImageProvider(image),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget showController() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _images.map((url) {
        int index = _images.indexOf(url);
        print('index' + index.toString());
        return Container(
          width: 10.0,
          height: 10.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index ? Colors.green : Colors.grey[100]),
        );
      }).toList(),
    );
  }

  Widget showProductInfo(Product? product) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          // color: Colors.grey[800],
          color: const Color(0xFF0E3311).withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 210,
                    child: Container(
                        // color: Colors.red,
                        child: Text(
                      _product!.name!,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
                  ),
                  Text('Stocks ' + _product!.stocks! + ' ' + _product!.unit!,
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('P ' + _product!.price + '/' + _product!.unit!,
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text(_product!.sold! + '' + _product!.unit! + ' sold',
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
            ],
          )),
    );
  }

  Future<bool> favoriteProduct(String id) async {
    setState(() {
      _favoriteColor = Colors.grey[300];
    });

    bool success = await favorite(id);

    if (success) {
      setState(() {
        var message = 'Product added to favorite.';
        if (_product!.isFavorite) {
          _product!.isFavorite = false;
          message = 'Product removed from favorite.';
        } else {
          _product!.isFavorite = true;
        }

        _favoriteColor = Colors.grey;

        Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green[600],
            textColor: Colors.white,
            fontSize: 16.0);
      });

      return true;
    }

    return true;
  }

  Widget buyNow(User? _seller, Product? product) {
    if (_showBuyNow == false) {
      return Text('');
    }
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            //color: Colors.red,
            child: Card(
                // margin: EdgeInsets.all(16),
                // elevation: 2,
                child: Container(
                    height: 86,
                    margin: EdgeInsets.only(left: 16),
                    decoration: BoxDecoration(
                      //color: Colors.green[900],
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // GestureDetector(
                        //   onTap: () {
                        //     print('tap profile');
                        //     Navigator.of(context).push(MaterialPageRoute(
                        //         builder: (context) => ViewProfile(user: _seller)));
                        //   },
                        //   child: Icon(Icons.account_circle_outlined),
                        // ),
                        // GestureDetector(
                        //   onTap: () {
                        //     print('tap chat');
                        //     Navigator.of(context).push(MaterialPageRoute(
                        //         builder: (context) => ViewChat(user: _seller)));
                        //   },
                        //   child: Icon(Icons.mark_chat_read_outlined),
                        // ),
                        Row(
                          children: [
                            Text(
                              'Qty',
                              style: TextStyle(color: Colors.grey),
                            ),
                            new Container(
                              height: 42,
                              width: 42,
                              //color: Colors.red,
                              decoration: BoxDecoration(
                                  // color: Colors.grey[300],
                                  // border: Border.all(
                                  //     //color: Colors.red[500],
                                  //     ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: new IconButton(
                                  color: Colors.transparent,
                                  icon: SvgPicture.asset(
                                    'assets/images/minus.svg',
                                    height: 42.6,
                                    width: 42.6,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    print('tap -');

                                    setState(() {
                                      // quantity++;
                                      if (_product!.qty <= 0) {
                                        return;
                                      }
                                      _product!.qty -= 1;
                                      _quantityController.text =
                                          _product!.qty.toString();
                                      _quantityController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: _quantityController
                                                      .text.length));
                                    });

                                    //This sets modal state
                                    // if (quantity != 0) {
                                    //   setModalState(() {
                                    //     quantity--;
                                    //     product.qty = quantity;
                                    //   });
                                    // }
                                  }),
                            ),
                            Container(
                              width: 55,
                              height: 40,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0.0, 0, 0.0),
                                child: new TextFormField(
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  keyboardType: TextInputType.number,
                                  controller: _quantityController,
                                  autofocus: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  decoration: new InputDecoration(
                                    fillColor: Colors.grey[100],
                                    filled: true,
                                    labelStyle:
                                        new TextStyle(color: Colors.black),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2.0),
                                      borderSide: BorderSide(
                                        color: Colors.grey[100]!,
                                        width: 0.0,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: button_beige_text_color),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _product!.qty = 0;
                                      _quantityController.text = '';
                                      if (val != '') {
                                        _product!.qty = int.parse(val);
                                        _quantityController.text =
                                            _product!.qty.toString();
                                      }
                                      _quantityController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: _quantityController
                                                      .text.length));
                                    });

                                    print(_quantityController.text);
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      _product!.qty = int.parse(val!);
                                      _quantityController.text =
                                          _product!.qty.toString();
                                      _quantityController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: _quantityController
                                                      .text.length));
                                    });
                                    print('saved');
                                  },
                                ),
                              ),
                            ),
                            Container(
                              height: 42,
                              width: 42,
                              //color: Colors.red,
                              decoration: BoxDecoration(
                                  // color: Colors.grey[300],
                                  // border: Border.all(
                                  //     //color: Colors.red[500],
                                  //     ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: new IconButton(
                                  icon: SvgPicture.asset(
                                    'assets/images/plus.svg',
                                    height: 42.6,
                                    width: 42.6,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    print('tap +');

                                    if (_product!.qty == 999) {
                                      return;
                                    }

                                    //This sets modal state
                                    setState(() {
                                      _product!.qty += 1;
                                      _quantityController.text =
                                          _product!.qty.toString();
                                      _quantityController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: _quantityController
                                                      .text.length));
                                    });

                                    // print(_product.qty.toString() + '--');
                                  }),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 114.0,
                          height: 35.0,
                          child: _product!.qty > 0 &&
                                  _product!.qty <=
                                      int.parse(_product!.stocks.toString()) &&
                                  _quantityController.text != ''
                              ? iconActionButton(
                                  context: context,
                                  icon: SvgPicture.asset(
                                    'assets/images/cart.svg',
                                    height: 28,
                                    width: 20,
                                    color: Colors.white,
                                  ),
                                  buttonColor: 'green',
                                  text: 'buy',
                                  product: product,
                                  productCallback: productCallback,
                                  // isLoading: _checkoutButtonLoading,
                                  callback: buy)
                              : Container(),
                        ),
                        // SizedBox(
                        //   width: 150.0,
                        //   height: 35.0,
                        //   child: new RaisedButton(
                        //     //elevation: 5.0,
                        //     shape: new RoundedRectangleBorder(
                        //         borderRadius: new BorderRadius.circular(5.0)),
                        //     color: Colors.green[700],
                        //     child: new Text('Buy',
                        //         style: new TextStyle(
                        //             fontSize: 12.0, color: Colors.white)),
                        //     onPressed: () {
                        //       addBasketModal(context, product);
                        //     },
                        //   ),
                        // ),
                      ],
                    )))));
  }

  void buy() {
    //
  }

  void productCallback(BuildContext? context, Product? product) {
    print('callback view product' + product!.qty.toString());

    // Cant buy on own product
    if (_showBuyNow == false) {
      return;
    }
    if (product.qty > 0) {
      Navigator.of(context!).push(MaterialPageRoute(
          builder: (context) => ConfirmOrder(product: product)));
    }
  }

  Widget productDetails() {
    return new Container(
      //padding: const EdgeInsets.all(16.0),
      child: ListView(children: [
        Stack(children: [
          showSliders(),
          Positioned(
            child: ButtonTheme(
                minWidth: 20.0,
                height: 22.0,
                child: productRating(widget.product)),
            top: 30,
            left: 30,
          ),
          Positioned(child: showController(), right: 30, top: 40),
          Positioned(
              child: showProductInfo(_product),
              right: 30,
              left: 30,
              bottom: 30),
        ]),
        // line(2),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 23, 0, 10),
            child: Text('Item Description', style: ThemeText.yellowLabel)),
        Padding(
          padding: EdgeInsets.only(left: 30, bottom: 10, right: 30),
          child: Text(_product!.description!),
        ),
        line(),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 0, 10),
            child: Text('Seller Details', style: ThemeText.yellowLabel)),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: userAccount(context, _seller,
                putActive: false, messageIcon: true)),
        Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
          child: Text(_product!.distance,
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),

        line(),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 0, 10),
            child: Text('Product Rating', style: ThemeText.yellowLabel)),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
          child: Row(
            children: [
              RatingBar.builder(
                initialRating: double.parse(_product!.ratings!),
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
                  print('_onClickRatingUpdate true');
                },
              ),
              Text(_product!.ratings!, style: ThemeText.yellowLabel24)
            ],
          ),
        ),

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
              children:
                  _product!.productRatings!.map((ProductRating productRating) {
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: userAccount(context, productRating.user,
                              isProfile: true,
                              putActive: false,
                              messageIcon: false)),
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: productRating.rating!,
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
                            itemSize: 15,
                            onRatingUpdate: (rating) {
                              // print(rating);
                            },
                          ),
                          Text(productRating.rating!.toString(),
                              style: ThemeText.yellowLabel15),
                          Padding(padding: EdgeInsets.only(right: 10)),
                          Text(
                            productRating.dateFormat!,
                          )
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      SizedBox(
                        child: Text(productRating.ratingMessage!),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )),
        Padding(padding: EdgeInsets.only(bottom: 130)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<ChangeNotifierUser>();

    // If not the same as the current user then show follow and message
    if (_seller!.id != user.getUserId()) {
      setState(() {
        _showBuyNow = true;
      });
    }

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: body_color,
      //   title: Text(
      //     'Product Details',
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   elevation: 0,
      //   leading: popArrow(context),
      //   actions: [
      //     Padding(
      //         padding: EdgeInsets.only(right: 16),
      //         child: GestureDetector(
      //             onTap: () {
      //               print('tap favorite');
      //               favoriteProduct(_product.id);
      //             },
      //             child: Icon(
      //               _product.isFavorite
      //                   ? Icons.favorite
      //                   : Icons.favorite_border_outlined,
      //               color: _favoriteColor,
      //             ))),
      //     Padding(
      //         padding: EdgeInsets.only(right: 16),
      //         child: Icon(
      //           Icons.more_horiz_outlined,
      //           color: Colors.grey,
      //         ))
      //   ],
      //   bottomOpacity: 0.0,
      // ),
      appBar:
          appBarTopWithBack(context, isMain: false, title: 'Product Details'),
      backgroundColor: body_color,
      body: productDetails(),
      bottomNavigationBar: SafeArea(child: buyNow(_seller, _product)),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: buyNow(_seller, _product),
    );
  }
}
