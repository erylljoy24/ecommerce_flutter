import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:magri/models/order.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/services/custom_route.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/modals/add_basket_modal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:magri/widgets/pages/products/add_product.dart';
import 'package:magri/widgets/pages/products/view_product.dart';

Widget showProducts(
    BuildContext context, User? currentUser, List<Product> products,
    {ScrollPhysics? physics,
    String? noRecordMessage = 'Nothing yet.',
    bool isLoading = false}) {
  if (products.length == 0 && !isLoading) {
    return Center(
      child: Text(noRecordMessage!),
    );
  }
  return Container(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 0.0),
      child: GridView.count(
        childAspectRatio: 0.7, // control the height
        shrinkWrap: true,
        physics: physics, // NeverScrollableScrollPhysics
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        // Generate 100 widgets that display their index in the List.
        children: products.map((Product product) {
          return productPortraitCard(context, product, currentUser!);
        }).toList(),
      ));
}

GestureDetector productPortraitCard(
        BuildContext context, Product product, User currentUser) =>
    GestureDetector(
      onTap: () {
        print('tap product');
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ViewProduct(product)));
        // Navigator.pushNamed(
        //   context,
        //   '/products/view',
        //   arguments: ProductArguments(product),
        // );
        // Navigate to product page
      },
      child: Card(
          //margin: EdgeInsets.all(5),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            //height: 200,
            decoration: BoxDecoration(
              //color: Colors.green[900],
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.all(0),
            child: Center(
                child: Column(
              //mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      image: DecorationImage(
                        // fit: BoxFit.fill,
                        //image: NetworkImage(product.imageUrl),
                        // image: CachedNetworkImageProvider(product.imageUrl!),
                        image:
                            CachedNetworkImageProvider(product.thumbImageUrl!),
                      ),
                    ),
                  ),
                  Positioned(
                    child: ButtonTheme(
                        minWidth: 40.0,
                        height: 29.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.yellow[700]!)),
                            elevation: 1,
                            primary: Colors.yellow[700],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 15,
                              ),
                              Text(product.ratings!,
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          onPressed: () {},
                        )),
                    bottom: 0,
                    right: 10,
                  )
                ]),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    product.name!,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'P' + product.price + '/' + product.unit!,
                            style: TextStyle(
                                color: greenColor, fontWeight: FontWeight.bold),
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Text(product.sold! + product.unit! + ' sold',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text((product.distance != '')?product.distance:'',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                      (currentUser.id! != product.user!.id!)
                          ? Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                  onTap: () {
                                    print('tap basket1');
                                    //_addBasket(product);
                                    addBasketModal(context, product);
                                    print(product.user!.id);
                                    //Navigator.pushNamed(context, route);
                                  },
                                  child: SvgPicture.asset(
                                    'assets/images/cart.svg',
                                    height: 28,
                                    width: 36,
                                    color: iconColor,
                                  )))
                          : Container()
                    ],
                  ),
                ),
              ],
            )),
          )),
    );

Widget singleProduct(BuildContext context, Product product,
    {double width = 42,
    double height = 42,
    bool isPriceStocks = false,
    double priceFontsize = 20.0,
    Order? order}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          productImage(context, product, width: width, height: height),
          // This is on add to cart
          isPriceStocks
              ? Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          product.name!,
                          style: ThemeText.greyUbuntuMedium,
                        ),
                      ),
                      Text(
                        'P' + product.price + '/' + product.unit!,
                        style: TextStyle(color: greenColor),
                      ),
                      Text(
                          product.sold! +
                              product.stocks! +
                              ' stocks | ' +
                              product.sold! +
                              product.unit! +
                              ' sold',
                          style: TextStyle(color: Colors.grey, fontSize: 12))
                    ],
                  ))
              : Container(),
          // Spacer(),
          // isPriceStocks
          //     ? new GestureDetector(
          //         onTap: () {
          //           // Navigator.pop(context);
          //         },
          //         child: Icon(
          //           Icons.close,
          //           color: Colors.grey,
          //         ))
          //     : Container(),
          // GestureDetector(
          //   onTap: () {
          //     print('tap product');

          //     // Navigator.of(context).push(MaterialPageRoute(
          //     //     builder: (context) => ViewProfile(user: seller)));
          //   },
          //   child: CircleAvatar(
          //     //backgroundColor: Colors.white,
          //     // backgroundImage: NetworkImage(_seller.image),
          //     backgroundImage: CachedNetworkImageProvider(product.imageUrl),

          //     radius: 20,
          //   ),
          // ),
        ],
      ),
      isPriceStocks
          ? Container()
          : Padding(
              padding: EdgeInsets.only(left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Text(
                      product.name!,
                      style: ThemeText.greyLabel,
                    ),
                  ),
                  Text(' x ' + product.qty.toString() + product.unit!,
                      style: ThemeText.greyLabel)
                ],
              )),
      // This is for total amount
      isPriceStocks
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('P ' + totalAmount(order, product),
                    style: TextStyle(
                        color: Colors.green, fontSize: priceFontsize)),
              ],
            ),
    ],
  );
}

totalAmount(Order? order, Product? product) {
  if (order != null) {
    return order.totalAmount.toString();
  }
  return (double.parse(product!.price) * product.qty).toString();
}

Widget productImage(BuildContext context, Product product,
    {double? width, double? height}) {
  return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ViewProduct(product)));
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
            image: CachedNetworkImageProvider(product.imageUrl!),
            //image: NetworkImage(product.imageUrl),
          ),
        ),
      ));
}

Widget singleProductLandScape(
    BuildContext context, Product product, bool isLoading,
    {Function(Product)? productCallback,
    bool isList = false,
    bool isSeller = false}) {
  return Card(
      // color: Colors.red,
      //margin: EdgeInsets.all(5),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        // color: Colors.red,
        //height: 200,
        // decoration: BoxDecoration(
        //   //color: Colors.green[900],
        //   borderRadius: BorderRadius.all(Radius.circular(15)),
        // ),
        padding: const EdgeInsets.all(0),
        child: Container(
            child: Row(
          //mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(children: [
              Container(
                // color: Colors.red,
                width: 130,
                height: isList ? 109 : 150, //  if list then the height is 109
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      //topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(5)),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(product.imageUrl!),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                    padding: EdgeInsets.only(left: 13),
                    child: SafeArea(child: productRating(product))),
              ),
            ]),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      // width: isList ? 80 : 110, // adjust the width
                      width: isList
                          ? MediaQuery.of(context).size.width * .28
                          : MediaQuery.of(context).size.width *
                              .28, // adjust the width

                      child: Container(
                          // color: Colors.red,
                          child: Text(
                        product.name!,
                        style: TextStyle(color: Colors.grey),
                      )),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.sold! + ' ' + product.unit! + ' sold',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Padding(
                          padding: EdgeInsets.only(bottom: 5),
                        ),
                        SizedBox(
                          // width: isList ? 80 : 110, // adjust the width
                          width: isList
                              ? MediaQuery.of(context).size.width * .28
                              : MediaQuery.of(context).size.width *
                                  .28, // adjust the width
                          child: Container(
                            // color: Colors.red,
                            child: Text(
                                'Stocks: ' +
                                    product.stocks! +
                                    ' ' +
                                    product.unit!,
                                style: TextStyle(
                                    color: greenColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Text((product.distance != '')?product.distance:'',
                            style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'P ' + product.price + '/' + product.unit!,
                      style: TextStyle(
                          color: greenColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                    Text(''),
                    GestureDetector(
                        onTap: () {
                          print('tap basket1');
                          //_addBasket(product);

                          if (isSeller) {
                            // Open edit
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddProduct(
                                      mode: 'edit',
                                      product: product,
                                    )));
                          } else {
                            addBasketModal(context, product);
                          }

                          // print(product.user!.id);

                          // print(isSeller.toString());
                        },
                        child: SvgPicture.asset(
                          isSeller
                              ? 'assets/images/edit.svg'
                              : 'assets/images/cart.svg',
                          height: 28,
                          width: 36,
                          color: iconColor,
                        ))
                    // GestureDetector(
                    //   onTap: () {
                    //     print('tap favorite map');
                    //     productCallback.call(product);
                    //     // favoriteProduct(product.id, product);
                    //   },
                    //   child: isLoading
                    //       ? SpinKitThreeBounce(
                    //           color: Colors.green,
                    //           size: 10,
                    //         )
                    //       : Icon(
                    //           product.isFavorite
                    //               ? Icons.favorite
                    //               : Icons.favorite_border_outlined,
                    //           color: Colors.grey),
                    // )
                  ],
                )),
          ],
        )),
      ));
}

Widget productRating(Product product) {
  return ButtonTheme(
      minWidth: 46.0,
      height: 29.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          textStyle: TextStyle(color: Colors.black),
          primary: Colors.yellow[700],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: yellowLabelRatingColor)),
        ),
        onPressed: () {
          // Respond to button press
        },
        child: Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.white,
              size: 15,
            ),
            Text(product.ratings!, style: TextStyle(color: Colors.white)),
          ],
        ),
      ));
}

class MapProducts extends StatefulWidget {
  final Product? product;
  final bool isList;
  final bool isSeller;

  MapProducts({this.product, this.isList = false, this.isSeller = false});

  @override
  _MapProductsState createState() => _MapProductsState();
}

class _MapProductsState extends State<MapProducts> {
  bool _isLoading = false;
  Future<bool> favoriteProduct(Product _product) async {
    setState(() {
      _isLoading = true;
    });
    bool success = await favorite(_product.id!);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      setState(() {
        var message = 'Product added to favorite.';
        if (_product.isFavorite) {
          _product.isFavorite = false;
          message = 'Product removed from favorite.';
        } else {
          _product.isFavorite = true;
        }

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

  GestureDetector productLandscapeCard(BuildContext context, Product product,
          {bool isList = false, bool isSeller = false}) =>
      GestureDetector(
        onTap: () {
          print('tap product landscape...');
          // Navigator.of(context).push(
          //     new MyCustomRoute(builder: (context) => ViewProduct(product)));
          if (isSeller) {
            // Open edit
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddProduct(
                      mode: 'edit',
                      product: product,
                    )));
          } else {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ViewProduct(product)));
          }
        },
        child: singleProductLandScape(context, product, _isLoading,
            productCallback: favoriteProduct,
            isList: isList,
            isSeller: isSeller),
      );

  Widget build(BuildContext context) {
    return productLandscapeCard(context, widget.product!,
        isList: widget.isList, isSeller: widget.isSeller);
  }
}
