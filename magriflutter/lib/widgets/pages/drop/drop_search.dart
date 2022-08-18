import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:magri/controllers/DropController.dart';
import 'package:magri/controllers/FilterController.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/models/drop.dart';
import 'package:magri/models/pin_information.dart';
import 'package:magri/models/product.dart';
import 'package:magri/services/location_service.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/modals/search_filter_modal.dart';
import 'package:magri/widgets/pages/products/view_product.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/drop_item.dart';
import 'package:magri/widgets/partials/partial_search.dart';
import 'package:magri/widgets/partials/seller_product.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../Constants.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class DropSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SearchState();
}

class _SearchState extends State<DropSearch>
    with SingleTickerProviderStateMixin<DropSearch> {
  Completer<GoogleMapController> _controller = Completer();

  final DropController dropController = Get.put(DropController());

  TabController? _tabController;
  // int _selectedIndex = 0;

  List<Product> _suggestedProducts = [];

  List<Widget> _tabList = [
    Tab(text: 'Nearby Drops'),
    Tab(text: 'Current Drops'),
    Tab(text: 'Drop History'),
  ];

  List<bool> _selectedCategories = [false, false, false, false];

  String _q = '';

  bool _preSearch = false;

  // Set<Marker> _markers = {};
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  late BitmapDescriptor sourceIcon;
  // late BitmapDescriptor magriIcon;

  BitmapDescriptor? destinationIcon;

  double pinPillPosition = -100;
  PinInformation? currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  PinInformation? sourcePinInfo;
  PinInformation? destinationPinInfo;

  int? _currentCategoryId;

  double? _latitude;
  double? _longitude;

  double? _distance;
  double? _priceMin;
  double? _priceMax;
  double? _ratings;

  bool _isLoading = false;

  bool _isList = true; //  data display

  LatLng? _lastMapPosition;

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  String? _search;

  int _current = 0;

  var _currentLocation = CameraPosition(
    target: LatLng(14.5839333, 121.0500025),
    zoom: 14.4746,
  );

  CarouselController buttonCarouselController = CarouselController();

  List<Product> _products = [];
  List<Product> _vegetables = [];
  List<Product> _fruits = [];
  List<Product> _condiments = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabList.length, vsync: this);

    _tabController!.addListener(() {
      setState(() {
        // _selectedIndex = _tabController!.index;
      });
      print("Selected Index: " + _tabController!.index.toString());

      // fetch(categoryId: _tabController!.index + 1);
    });

    print('drop_search.dart');

    setIcon();
    // setMagriIcon();

    // Get the location first then fetch the products
    _determinePosition().then((value) {
      // fetch(categoryId: 1);
    });

    // fetchDrop();

    dropController.getItems();
  }

  Future fetchSuggestions({int? categoryId, bool? suggestion = false}) async {
    print('fetchSuggestions:' + categoryId.toString());

    if (!mounted) {
      return;
    }

    setState(() {
      // _preSearch = false;
      _currentCategoryId = categoryId;
    });

    if (suggestion!) {
      _latitude = null;
      _longitude = null;
      _distance = null;
      _priceMin = null;
      _priceMax = null;
      _ratings = null;
    }

    fetchProducts(
            categoryId: _currentCategoryId,
            latitude: _latitude,
            longitude: _longitude,
            distance: _distance,
            priceMin: _priceMin,
            priceMax: _priceMax,
            ratings: _ratings,
            q: _q)
        .then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        _products.clear();
        _suggestedProducts.clear();
        if (dataItems != null) {
          dataItems.forEach((item) {
            _suggestedProducts.add(Product.fromMap(item));
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        _currentLocation = CameraPosition(
          target: target,
          zoom: 14.4746,
        );

        _latitude = target.latitude;
        _longitude = target.longitude;
        // _latitude = 14.554592;
        // _longitude = 121.0156373;

        // Set the user latitude and longitude
        Provider.of<ChangeNotifierUser>(context, listen: false)
            .setLatLang(target);

        print('My latitude: ' + target.latitude.toString());
        print('My longitude: ' + target.longitude.toString());
      }
    });
    _goCurrentLocation();
    return true;
  }

  Future<void> _goCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
  }

  Widget showDropSliders() {
    if (_isList) {
      //  lists
      return Container();
    }

    return GetX<DropController>(
      builder: (controller) {
        return CarouselSlider(
          options: CarouselOptions(
              autoPlay: false,
              height: 212,
              enableInfiniteScroll: false,
              //enlargeCenterPage: true,
              viewportFraction: 0.90,
              //aspectRatio: 5.0,
              //initialPage: 2,
              //onPageChanged: callbackFunction,
              //scrollDirection:Axis.vertical
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                  _currentLocation = CameraPosition(
                    target: LatLng(controller.items.value[index].latitude!,
                        controller.items.value[index].longitude!),
                    zoom: 14.4746,
                  );
                });

                _goCurrentLocation();

                print('product showing: ' + index.toString());
                print(controller.items.value[index].name);
                print(controller.items.value[index].latitude.toString());
                print(controller.items.value[index].longitude.toString());
              }),
          carouselController: buttonCarouselController,
          items: controller.items.value.map((Drop drop) {
            return DropItem(drop: drop);
          }).toList(),
        );
      },
    );
  }

  void search(String q) {
    // if (q != null && q != '') {
    setState(() {
      _q = q;
    });

    print('callback: ' + q);

    // process the search
    // fetch();
    // }
  }

  Future getSuggestions(String pattern) async {
    print('getSuggestions: ' + pattern);

    // process the search
    setState(() {
      _q = pattern;
    });
    await fetchSuggestions();

    return _suggestedProducts;
  }

  Widget showTypeHeadSearch() {
    return TypeAheadField(
      debounceDuration: const Duration(milliseconds: 400),
      hideOnEmpty: true,
      textFieldConfiguration: TextFieldConfiguration(
          autofocus: true,
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(fontStyle: FontStyle.normal),
          decoration: InputDecoration(border: OutlineInputBorder())),
      suggestionsCallback: (pattern) async {
        return await getSuggestions(pattern);
      },
      itemBuilder: (context, suggestion) {
        Product product = suggestion as Product; // cast suggestion as product
        return ListTile(
          // leading: Icon(Icons.shopping_cart),
          title: Text(product.name!),
          // subtitle: Text('Php ' + product.price),
        );
      },
      onSuggestionSelected: (suggestion) {
        Product product = suggestion as Product; // cast suggestion as product
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ViewProduct(product)));
      },
    );
  }

  Widget showSearchButton() {
    // return showTypeHeadSearch();
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 10, 0),
        child: Row(children: [
          SizedBox(
              // width: 200,
              // width: MediaQuery.of(context).size.width / 1.35,
              width: MediaQuery.of(context).size.width / 1.1,
              child: PartialSearch(
                placeholder: 'Enter keyword here',
                color: Colors.grey[100],
                callbackSubmitted: search,
              )),
          // Padding(
          //     padding: EdgeInsets.only(left: 10),
          //     child: GestureDetector(
          //         onTap: () {
          //           searchFilterModal(context);
          //         },
          //         child: Icon(
          //           Icons.filter_alt_sharp,
          //           color: Colors.green,
          //         )))
        ]));
  }

  final FilterController filterController = Get.put(FilterController());

  void searchFilterModal(BuildContext context) {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: 380,
                // padding: EdgeInsets.all(29.0),
                color: Colors.white,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding:
                              EdgeInsets.only(top: 16, left: 37, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              popArrow(context, color: Colors.grey),
                              // Obx(() => Text(
                              //       filterController.filterTitle.value,
                              //       style: TextStyle(fontSize: 22),
                              //     )),
                              Text(
                                'Filter',
                                style: TextStyle(fontSize: 22),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    filterController.clearAll();
                                  },
                                  child: Text(
                                    'Clear All',
                                    style: TextStyle(color: Colors.grey),
                                  )),
                            ],
                          )),
                      // Spacer(),
                      line(2),
                      defaultForm(context),
                      Spacer(),
                      SafeArea(
                          child: Container(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  iconActionButton(
                                      context: context,
                                      text: 'view',
                                      // productCallback: productCallback,
                                      callback: callback),
                                ],
                              )))
                    ],
                  ),
                ),
              ));
        });
      },
    );

    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    print('modal closed hehe');
    // filterController.filterTitle.value = 'Filter';
    setState(() {
      _distance = filterController.distance.value;
      _priceMin = filterController.priceMin.value;
      _priceMax = filterController.priceMax.value;
      _ratings = filterController.ratings.value;
    });

    // fetch(categoryId: _currentCategoryId);
  }

  Widget defaultForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 37, right: 16),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              filterController.showDistance.value = true;
              filterController.filterTitle.value = 'Distance';
              filterController.form.value = 'distance';
              distanceFilterModal(context);
            },
            leading: Icon(Icons.check),
            title: Text('Distance'), // distanceLabel
            subtitle: Obx(() => Text(filterController.distanceLabel.string)),
          ),
          ListTile(
            onTap: () {
              filterController.showPrice.value = true;
              filterController.filterTitle.value = 'Price';
              filterController.form.value = 'price';
              priceFilterModal(context);
            },
            leading: Icon(Icons.check),
            title: Text('Price'),
            subtitle: Obx(() => Text(filterController.priceLabel.string)),
          ),
          ListTile(
            onTap: () {
              filterController.showRate.value = true;
              filterController.filterTitle.value = 'Rate';
              filterController.form.value = 'rate';
              rateFilterModal(context);
            },
            leading: Icon(Icons.check),
            title: Text('Rate'),
            subtitle: Obx(() => Text(filterController.rateLabel.string)),
          ),
        ],
      ),
    );
  }

  void callback() {
    print('callback');
    Get.back();
    // filterController.priceMin.value++;
  }

  // Widget showSearchButton() {
  //   return Padding(
  //       padding: EdgeInsets.fromLTRB(16, 10, 16, 2),
  //       child: TextFormField(
  //         initialValue: '',
  //         maxLines: 1,
  //         keyboardType: TextInputType.emailAddress,
  //         autofocus: false,
  //         decoration: new InputDecoration(
  //           filled: true,
  //           fillColor: Colors.white,
  //           hintText: 'Search',
  //           prefixIcon: const Icon(
  //             Icons.search,
  //             color: Colors.grey,
  //           ),
  //           //labelText: 'Search',
  //           labelStyle: new TextStyle(color: Colors.black),
  //           enabledBorder: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(2.0),
  //             borderSide: BorderSide(
  //               color: Colors.green,
  //               width: 0.2,
  //             ),
  //           ),
  //           focusedBorder: UnderlineInputBorder(
  //             borderSide: BorderSide(color: Colors.green),
  //           ),
  //         ),
  //         validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
  //         onSaved: (value) => _search = value.trim(),
  //       ));
  // }

  Widget showRowButtons() {
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 5, 16, 0),
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: false,
            height: 25,
            enableInfiniteScroll: false,
            //enlargeCenterPage: true,
            viewportFraction: 0.34,
            //aspectRatio: 5.0,
            initialPage: 1,
            //onPageChanged: callbackFunction,
            //scrollDirection:Axis.vertical
          ),
          //carouselController: buttonCarouselController,
          items: [
            //actionButton('||', Icons.home),
            // actionButton('Seller', Icons.person, 0),
            actionButton('Vegetables', Icons.adjust_sharp, 1),
            actionButton('Fruits', Icons.adjust_sharp, 2),
            actionButton('Condiments', Icons.scatter_plot_rounded, 3),
          ],
        ));

    // return Padding(
    //     padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
    //       children: [
    //         actionButton('||', Icons.home),
    //         actionButton('Seller', Icons.home),
    //         actionButton('Vegetables', Icons.home),
    //         actionButton('Fruits', Icons.home),
    //         actionButton('Condiments', Icons.home),
    //         //actionButton('buttons'),
    //       ],
    //     ));
  }

  Widget actionButton(String label, IconData icon, int categoryId) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 7, 0),
        child: ButtonTheme(
            //minWidth: 300.0,
            //height: 100.0,
            child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            primary: _selectedCategories[categoryId]
                ? Colors.green[700]
                : Colors.white,
          ),
          onPressed: () {
            print('fetch by category');
            // Change the content of the list
            setState(() {
              _currentCategoryId = categoryId;
            });
            // fetch(categoryId: categoryId);

            setState(() {
              _selectedCategories[0] = false;
              _selectedCategories[1] = false;
              _selectedCategories[2] = false;
              _selectedCategories[3] = false;

              _selectedCategories[categoryId] =
                  !_selectedCategories[categoryId];
            });
          },
          // textColor:
          //     _selectedCategories[categoryId] ? Colors.white : Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon),
              Text(
                label,
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ))

        // RaisedButton(
        //   onPressed: () {},
        //   color: Colors.white,
        //   textColor: Colors.grey,
        //   child: Row(
        //     children: <Widget>[
        //       //Icon(icon),
        //       Text(label),
        //     ],
        //   ),
        // )

        );
    // return ElevatedButton(
    //   style: ElevatedButton.styleFrom(
    //     textStyle: TextStyle(color: Colors.black),
    //     primary: Colors.white,
    //     shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(5.0),
    //         side: BorderSide(color: Colors.green[800]!)),
    //   ),
    //   onPressed: () {
    //     // Respond to button press
    //   },
    //   child: Text(label,
    //       style: TextStyle(
    //         // fontWeight: FontWeight.w500,
    //         color: Colors.grey,
    //         fontSize: 10,
    //       )),
    // );
  }

  void onMapCreated(GoogleMapController controller) {
    if (!_controller.isCompleted) {
      _controller.complete(controller);
    }

    // MarkerId markerId = MarkerId('magri-marker');
    // LatLng position = LatLng(37.43296265331129, -122.08832357078792);
    // Marker marker = Marker(
    //     markerId: markerId,
    //     position: position,
    //     draggable: false,
    //     onTap: () {
    //       // Open the Shop Page
    //     },
    //     icon: magriIcon);
    // setState(() {
    //   _markers[markerId] = marker;
    // });

    // getAddress(LatLng(37.43296265331129, -122.08832357078792)).then((value) {
    //   // print(value);
    // });
  }

  void setIcon() async {
    if (!mounted) {
      return;
    }
    // https://www.flaticon.com/packs/fruits-and-vegetables
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 10.0),
            "assets/images/vegetable.png")
        .then((value) {
      if (!mounted) {
        return false;
      }
      setState(() {
        sourceIcon = value;
      });

      print('pin');
    });
  }

  // void setMagriIcon() async {
  //   if (!mounted) {
  //     return;
  //   }
  //   // https://www.flaticon.com/packs/fruits-and-vegetables
  //   BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 10.0),
  //           "assets/images/map_marker.png")
  //       .then((value) {
  //     if (!mounted) {
  //       return false;
  //     }
  //     setState(() {
  //       magriIcon = value;
  //     });

  //     print('pin');
  //   });
  // }

  void setMapPin(Product product, [int index = 0]) {
    // add the source marker to the list of markers
    MarkerId markerId = MarkerId('product_id' + product.id!);
    LatLng position = LatLng(product.latitude, product.longitude);
    Marker marker = Marker(
        markerId: markerId,
        position: position,
        draggable: false,
        onTap: () {
          // Open the Shop Page
          sellerProductModal(context, product.user);
          print('tap marker');
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 150;

            buttonCarouselController.animateToPage(index,
                duration: Duration(milliseconds: 300), curve: Curves.linear);

            //_current = index;
            // _currentLocation = CameraPosition(
            //   target: LatLng(product.latitude, product.longitude),
            //   zoom: 14.4746,
            // );
          });
        },
        icon: sourceIcon);
    setState(() {
      _markers[markerId] = marker;
    });

    print('add pin marker');
  }

  Future<Map<String, String>> getAddress(LatLng location) async {
    try {
      // final endpoint =
      //     'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location?.latitude},${location?.longitude}'
      //     '&key=${widget.apiKey}&language=${widget.language}';
      String apiKey = GOOGLE_MAPS_API_KEY;
      final endpoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}'
          '&key=$apiKey&language=en';

      final result = await http.get(Uri.parse(endpoint));

      Map<String, dynamic>? map = json.decode(result.body);

      print(map!['results'][0]['formatted_address']);

      // final response = jsonDecode((await http.get(Uri.parse(endpoint),
      //         headers: await LocationUtils.getAppHeaders()))
      //     .body);

      // return {
      //   "placeId": response['results'][0]['place_id'],
      //   "address": response['results'][0]['formatted_address']
      // };
    } catch (e) {
      print(e);
    }

    return {"placeId": "null", "address": "null"};
  }

  PreferredSizeWidget appBar() {
    return appBarTop(
      context,
      withBack: true,
      isLogoHidden: true,
      title: 'Magri Drop',
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: Material(
            // Set the background color of the tab here
            color: Colors.white,
            //elevation: 1,
            shadowColor: Colors.grey,
            child: Column(
              children: [
                showSearchButton(),
                Container(
                    margin: EdgeInsets.zero,
                    child: TabBar(
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
                    ))
              ],
            )),
      ),
    );
  }

  Widget googleMap() {
    return GoogleMap(
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      //mapType: MapType.hybrid,
      markers: Set<Marker>.of(_markers.values),
      // markers: _markers,
      initialCameraPosition: _currentLocation,
      onMapCreated: onMapCreated,
      // onMapCreated: (GoogleMapController controller) {
      //   _controller.complete(controller);
      // },
      // handle the tapping on the map
      // to dismiss the info pill by
      // resetting its position
      onTap: (LatLng location) {
        setState(() {
          pinPillPosition = -100;
        });
      },
      onCameraMove: (CameraPosition position) {
        // _lastMapPosition = position.target;
        // MarkerId markerId = MarkerId('magri-marker');
        // Marker marker = _markers[markerId]!;
        // Marker updatedMarker = marker.copyWith(
        //   positionParam: _lastMapPosition,
        // );
        // setState(() {
        //   _markers[markerId] = updatedMarker;
        // });
      },
      onCameraIdle: () async {
        // print(
        //     "onCameraIdle#_lastMapPosition = $_lastMapPosition");

        // getAddress(_lastMapPosition!).then((value) {
        //   // print(value);
        // });
      },
    );
  }

  Widget dropList({String type = 'nearby'}) {
    return Padding(
      padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 100),
      child: GetX<DropController>(
        builder: (controller) {
          return controller.items.value.length <= 0
              ? Center(
                  child: controller.isLoading.value
                      ? spin()
                      : Text('Nothing found.'))
              : ListView(
                  children: controller.items.value.map((Drop drop) {
                  return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: DropItem(drop: drop, isList: _isList));
                }).toList());
        },
      ),
    );
    // return Padding(
    //     padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 100),
    //     child: dropController.items.value.length <= 0
    //         ? Center(child: _isLoading ? Text('') : Text('Nothing found.'))
    //         : ListView(
    //             children: dropController.items.value.map((Drop drop) {
    //             return Container(
    //                 margin: EdgeInsets.only(bottom: 15),
    //                 child: DropItem(drop: drop, isList: _isList));
    //           }).toList()));
  }

  Widget greenControl() {
    return Positioned(
        bottom: _preSearch
            ? 10
            : _isList
                ? 30
                : 220,
        right: 32,
        child: Row(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 4,
                height: 39.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(color: Colors.white),
                    primary: buttonGreenColor,
                  ),
                  onPressed: () async {
                    setState(() {
                      _isList = !_isList;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isList ? Icons.map : Icons.list),
                      _isList ? Text('Map') : Text('List'),
                    ],
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(left: 16),
            ),
            _isList
                ? Container()
                : SizedBox(
                    width: MediaQuery.of(context).size.width / 7,
                    height: 39.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: Colors.white),
                        primary: buttonGreenColor,
                        // shape: RoundedRectangleBorder(
                        //     borderRadius:
                        //         BorderRadius.circular(5.0),
                        //     side: BorderSide(
                        //         color: selectedColor(buttonColor))),
                      ),
                      onPressed: () async {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon(Icons.),
                          SvgPicture.asset(
                            'assets/images/show-location.svg',
                            height: 21.6,
                            width: 21.6,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )),
          ],
        ));
  }

  Future<void> _refreshDrops() async {
    print('pull');
    // fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBar(),
      body: LayoutBuilder(
          builder: (context, constraints) =>
              Stack(fit: StackFit.expand, // remove if not needed
                  children: <Widget>[
                    !_isList
                        ? googleMap()
                        : Container(
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                                RefreshIndicator(
                                    color: Colors.green[600],
                                    onRefresh: _refreshDrops,
                                    child: dropList(type: 'nearby')),
                                RefreshIndicator(
                                    color: Colors.green[600],
                                    onRefresh: _refreshDrops,
                                    child: dropList(type: 'current')),
                                RefreshIndicator(
                                    color: Colors.green[600],
                                    onRefresh: _refreshDrops,
                                    child: dropList(type: 'history')),
                              ])),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                          child: _isLoading
                              ? SpinKitThreeBounce(
                                  color: Colors.green,
                                  size: 40,
                                )
                              : showDropSliders()),
                    ),
                    greenControl(),
                  ])),
    );
  }
}
