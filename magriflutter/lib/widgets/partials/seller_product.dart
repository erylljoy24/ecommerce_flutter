import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:magri/widgets/pages/products/view_product.dart';
import 'package:magri/widgets/pages/view_profile.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void sellerProductModal(BuildContext context, User? user) {
  showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    // enableDrag: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    builder: (BuildContext context) {
      return Container(
        height: 400,
        padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
        //color: Colors.grey[100],
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  userAccount(context, user),
                  SizedBox(
                    width: 100.0,
                    height: 30.0,
                    child: new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        //elevation: 5.0,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            side: BorderSide(color: Colors.green[700]!)),
                        primary: Colors.white,
                      ),
                      child: new Text('View Seller',
                          style: new TextStyle(
                              fontSize: 12.0, color: Colors.black)),
                      onPressed: () {
                        // View Seller
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewProfile(user: user)));
                      },
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 16)),
              Expanded(
                child: SellerProducts(user),
              )
            ],
          ),
        ),
      );
    },
  );
}

class SellerProducts extends StatefulWidget {
  final User? user;
  SellerProducts(this.user);

  @override
  _SellerProductsState createState() => _SellerProductsState();
}

class _SellerProductsState extends State<SellerProducts> {
  bool _isLoading = false;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();

    print('seller_product.dart');

    fetch();
  }

  void fetch() {
    print('fetch');

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    fetchProducts(userId: widget.user!.id).then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (dataItems != null) {
          dataItems.forEach((item) {
            _products.add(Product.fromMap(item));
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

  Future<bool> favoriteProduct(String id, Product _product) async {
    bool success = await favorite(id);

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

  GestureDetector productLandscapeCard(BuildContext context, Product product) =>
      GestureDetector(
        onTap: () {
          print('tap product landscape...');

          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewProduct(product)));
        },
        child: Card(
            //margin: EdgeInsets.all(5),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              height: 120,
              // decoration: BoxDecoration(
              //   //color: Colors.green[900],
              //   borderRadius: BorderRadius.all(Radius.circular(15)),
              // ),
              padding: const EdgeInsets.all(0),
              child: Container(
                  child: Row(
                //mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(children: [
                    Container(
                      width: 130,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            //topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          // image: NetworkImage(product.imageUrl),
                          image: CachedNetworkImageProvider(product.imageUrl!),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: SafeArea(
                              child: ButtonTheme(
                                  minWidth: 20.0,
                                  height: 20.0,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.yellow[700]!)),
                                      primary: Colors.yellow[700],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.black,
                                          size: 12,
                                        ),
                                        Text(product.ratings!),
                                      ],
                                    ),
                                    onPressed: () {},
                                  )))),
                    ),
                  ]),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Container(
                                //color: Colors.red,
                                child: Text(
                              product.name!,
                            )),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.wb_iridescent_sharp,
                                color: Colors.blue,
                                size: 20,
                              ),
                              Text('Per ' + product.unit!,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.pin_drop_sharp,
                                color: Colors.blue,
                                size: 18,
                              ),
                              Text(product.distance,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 12)),
                            ],
                          ),
                          Text(product.stocks! + ' stocks',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12))
                        ],
                      )),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'P ' + product.price,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.right,
                          ),
                          GestureDetector(
                            onTap: () {
                              print('tap favorite map');
                              favoriteProduct(product.id!, product);
                            },
                            child: Icon(
                                product.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border_outlined,
                                color: Colors.grey),
                          )
                        ],
                      )),
                ],
              )),
            )),
      );

  Widget build(BuildContext context) {
    return _isLoading
        ? SpinKitThreeBounce(
            color: Colors.green,
            size: 30,
          )
        : ListView(
            // physics: new NeverScrollableScrollPhysics(),
            children: _products.map((Product product) {
              return productLandscapeCard(context, product); // make it gridview
            }).toList(),
          );
  }
}
