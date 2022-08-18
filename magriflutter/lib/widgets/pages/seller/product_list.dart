import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/pages/products/add_product.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/partial_search.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class ProductList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final UserController userController = Get.put(UserController());

  bool _isLoading = false;

  List<Product> _products = [];
  List<Product> draftProducts = [];
  String _q = '';
  String _userId = '';

  String _noRecord = 'Nothing yet.';

  @override
  void initState() {
    super.initState();
    loadDrafts();
    currentFile('product_list.dart');
    fetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future loadDrafts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringedJson = prefs.getString('drafts');
    List<dynamic>? lsit = json.decode(stringedJson!);
    print('_printList ${json.decode(stringedJson)}');
    lsit?.forEach((item) {
      var decodedString = json.decode(item);

      _products.add(Product(
          '',
          '',
          decodedString['name']!,
          decodedString['description']!,
          '',
          [],
          '',
          decodedString['price']!.toString(),
          decodedString['stocks']!.toString(),
          '',
          int.parse(decodedString['stocks']!),
          decodedString['unit']!.toString(),
          decodedString['latitude']!,
          decodedString['longitude']!,
        )
      );
    });
  }

  void fetch([int? categoryId]) {
    setState(() {
      _isLoading = true;
      _userId = userController.user!.id!.toString();
    });
    print('categoryId:' + categoryId.toString());
    print('fetch');

    if (!mounted) {
      return;
    }

    // setState(() {
    //   _currentCategoryId = categoryId;
    //   _isLoading = true;
    // });

    fetchProducts(userId: _userId, q: _q).then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        // _products.clear();
        // // Clear the products if user selected category
        // if (categoryId != null) {
        //   _products.clear();
        // }
        //_isLoading = true;
        List<Product> tempList = [];
        print('_print');
        if (dataItems != null) {
          dataItems.forEach((item) {
            tempList.add(Product.fromMap(item));
          });
          _products.addAll(tempList);
        }

        _isLoading = false;
      });
    });
  }

  Widget showSearchButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(29, 10, 29, 10),
        child: Row(children: [
          SizedBox(
              // width: 200,
              width: MediaQuery.of(context).size.width / 1.2,
              child: PartialSearch(
                placeholder: 'Potatoes, Carrots, etc',
                color: Colors.grey[100],
                callbackSubmitted: search,
              )),
        ]));
  }

  void search(String q) {
    setState(() {
      _q = q;
      _noRecord = 'No Record found';
    });

    print('callback: ' + q);

    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBarTopWithBack(
      //   context,
      //   isMain: false,
      //   title: 'My Inventory',
      //   bottom: PreferredSize(
      //     preferredSize: Size.fromHeight(60), // 49
      //     child: Material(
      //         // Set the background color of the tab here
      //         color: Colors.white,
      //         //elevation: 1,
      //         shadowColor: Colors.grey,
      //         child: showSearchButton()),
      //   ),
      // ),
      appBar: appBarTop(
        context,
        isLogoHidden: true,
        title: 'My Inventory',
        searchBar: showSearchButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60), // 49
          child: Material(
              // Set the background color of the tab here
              color: Colors.white,
              //elevation: 1,
              shadowColor: Colors.grey,
              child: showSearchButton()),
        ),
      ),
      // showSearchButton
      // backgroundColor: body_color,
      body: new Center(
        child: _isLoading
            ? spin()
            : Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.only(
                        top: 30, left: 30, right: 30, bottom: 50),
                    child: _products.length <= 0
                        ? Center(child: _isLoading ? Text('') : Text(_noRecord))
                        : ListView(
                            children: _products.map((Product product) {
                            return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                child: MapProducts(
                                  product: product,
                                  isList: true,
                                  isSeller: true,
                                ));
                          }).toList()))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: greenColor,
        child: Image.asset(
          'assets/images/add product.png',
          height: 30,
          width: 30,
        ),
        shape: RoundedRectangleBorder(),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddProduct()));
        },
      ),
    );
  }
}
