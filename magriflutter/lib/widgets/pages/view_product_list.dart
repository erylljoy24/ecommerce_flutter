import 'dart:async';
import 'package:flutter/material.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/services/location_service.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/partial_search.dart';
import 'package:magri/widgets/partials/product.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/colors.dart';
import 'package:flutter/services.dart';
import 'package:magri/util/helper.dart';

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

class ViewProductList extends StatefulWidget {
  final String listType;
  ViewProductList({
    required this.listType, //  can be topseller, mostrecent
  });
  @override
  State<StatefulWidget> createState() => new _ViewProductListState();
}

class _ViewProductListState extends State<ViewProductList>
    with SingleTickerProviderStateMixin {
  final _debouncer = Debouncer(milliseconds: 500);
  String _q = '';

  final searchController = TextEditingController();

  bool _isShowResult = false;

  bool _isLoading = false;

  List<Product> _products = [];

  User? _seller;

  String _headerTitle = 'Top Seller';

  int _itemCount = 10;

  double? _latitude;
  double? _longitude;

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
    setState(() {
      _isLoading = true;
    });
    fetchProducts(
            listType: widget.listType,
            latitude: _latitude,
            longitude: _longitude,
            q: _q)
        .then((dataItems) {
      setState(() {
        _products.clear();
        if (dataItems != null) {
          dataItems.forEach((item) {
            _products.add(Product.fromMap(item));
          });
        }
        _isLoading = false;
      });
    });
  }

  // _setSearchValue(String q) {
  //   _q = q;
  //   fetch();
  // }

  // Future fetchProfile(String id) async {
  //   final SharedPreferences prefs = await _prefs;

  //   setState(() {
  //     //_isLoading = true;
  //   });

  //   try {
  //     var bearerToken = 'Bearer ' + token;
  //     var result = await http.get(Constants.base + '/users/' + id,
  //         headers: <String, String>{
  //           'Accept': 'application/json',
  //           'Authorization': bearerToken
  //         });

  //     Map<String, dynamic> map = json.decode(result.body);
  //     print(Constants.base + '/users/' + id + result.statusCode.toString());

  //     if (result.statusCode == 200) {
  //       return map['data'];
  //     }
  //   } catch (e) {
  //     print('Error: ' + e.toString());
  //     //setState(() {});
  //   }

  //   return null;
  // }

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLoading = true;
      if (widget.listType == 'topseller') {
        _headerTitle = 'Top Seller';
      }
      if (widget.listType == 'mostrecent') {
        _headerTitle = 'New Items';
      }
      if (widget.listType == 'featured') {
        _headerTitle = 'Featured Items';
      }

      if (widget.listType == 'favorites') {
        _headerTitle = 'My Favorites';
      }

      if (widget.listType == 'recentlyviewed') {
        _headerTitle = 'Recently Viewed';
      }

      // print(_seller.reviews);
    });

    // fetchProfile(widget.listType).then((seller) {
    //   //print(seller['products']);
    //   // seller['email'];
    //   setState(() {
    //     if (seller != null) {
    //       seller['products'].forEach((item) {
    //         _products.add(Product.fromMap(item));
    //       });
    //     }
    //   });
    // });
    fetch();
    _determinePosition().then((value) {
      fetch();
    });

    //searchController.addListener(_setSearchValue); // init

    print('view_product_list.dart');
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Widget showSearchButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(29, 10, 29, 10),
        child: Row(children: [
          SizedBox(
              // width: 200,
              width: MediaQuery.of(context).size.width / 1.2,
              child: PartialSearch(
                placeholder: 'Search ...',
                color: Colors.grey[100],
                callbackSubmitted: search,
              )),
        ]));
  }

  void search(String q) {
    setState(() {
      _q = q;
    });

    print('callback: ' + q);

    fetch();
  }

  // Widget showSearchInput() {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width / 1.6,
  //     height: 45.0,
  //     child: Padding(
  //         padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0.0),
  //         child: PartialSearch(
  //           placeholder: 'Search',
  //           //color: Colors.white,
  //           callbackSubmitted: _setSearchValue,
  //         )),
  //   );
  // }

  Future<void> _refreshProducts() async {
    print('pull');
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark); // For battery color
    var currentUser = context.read<ChangeNotifierUser>().getUser();
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTopWithBack(
        context,
        isMain: false,
        title: _headerTitle,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(57),
          child: Material(
              // Set the background color of the tab here
              color: Colors.white,
              //elevation: 1,
              shadowColor: Colors.grey,
              child: Column(
                children: [
                  showSearchButton(),
                ],
              )),
        ),
      ),
      // appBar: AppBar(
      //   backgroundColor: body_color,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Padding(
      //         padding: EdgeInsets.only(left: 0, bottom: 0),
      //         child: showSearchInput(),
      //       ),
      //       Padding(
      //         padding: EdgeInsets.only(right: 16),
      //         child: Icon(
      //           Icons.more_horiz,
      //           color: Colors.grey,
      //         ),
      //       ),
      //     ],
      //   ),
      //   elevation: 0,
      //   leading: popArrow(context),
      //   bottomOpacity: 0.0,
      // ),
      body: new Container(
          padding: const EdgeInsets.only(left: 16, right: 10),
          // margin: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(
              //   _headerTitle,
              //   style: TextStyle(fontSize: 20),
              // ),
              // Padding(
              //   padding: EdgeInsets.only(top: 0),
              //   child: _isLoading
              //       ? Center(
              //           child: spin(),
              //         )
              //       : Container(),
              // ),
              // RefreshIndicator(
              //     color: Colors.green[600],
              //     onRefresh: _refreshProducts,
              //     child: showProducts('fruits')),
              _isLoading
                  ? shim(context, _isLoading)
                  : Expanded(
                      child: showProducts(context, currentUser, _products,
                          noRecordMessage: 'No record found.',
                          isLoading: _isLoading))
            ],
          )),
    );
  }
}
