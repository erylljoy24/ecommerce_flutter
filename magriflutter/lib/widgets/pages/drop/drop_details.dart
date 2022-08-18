import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magri/models/drop.dart';
import 'package:magri/models/dropproduct.dart';
import 'package:magri/models/productcontribution.dart';
import 'package:magri/widgets/pages/drop/add_contribution.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/drop_item.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:image_stack/image_stack.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class DropDetails extends StatefulWidget {
  final Drop? drop;
  DropDetails({this.drop});
  @override
  State<StatefulWidget> createState() => new _ViewProductState();
}

class _ViewProductState extends State<DropDetails>
    with SingleTickerProviderStateMixin<DropDetails> {
  bool _isLoading = false;
  double progress = 0.2;

  TabController? _tabController;

  List<Widget> _tabList = [
    Tab(text: 'Drop Details'),
    Tab(text: 'Product List'),
    Tab(text: 'My Contributions'),
  ];

  List<String> _sellerImages = <String>[
    "https://images.unsplash.com/photo-1458071103673-6a6e4c4a3413?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
    "https://images.unsplash.com/photo-1518806118471-f28b20a1d79d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=400&q=80",
    "https://images.unsplash.com/photo-1470406852800-b97e5d92e2aa?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80",
    "https://images.unsplash.com/photo-1473700216830-7e08d47f858e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80"
  ];

  int _current = 0;

  List<String> _images = [];

  User? _seller;

  bool _showBuyNow = false;

  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();

    currentFile('drop_details.dart');

    _tabController = TabController(length: _tabList.length, vsync: this);

    _tabController!.addListener(() {
      setState(() {
        // _selectedIndex = _tabController!.index;
      });
      print("Selected Index: " + _tabController!.index.toString());

      // fetch(categoryId: _tabController!.index + 1);
    });

    _quantityController.selection = TextSelection.fromPosition(
        TextPosition(offset: _quantityController.text.length));

    getUser();

    setState(() {
      // _drop = widget.drop;
    });
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

  void dropCallback() {
    print('dropCallback view product');

    // if (product.qty > 0) {
    //   Navigator.of(context!).push(MaterialPageRoute(
    //       builder: (context) => ConfirmOrder(product: product)));
    // }
  }

  Widget joinDropButton() {
    return Padding(
        padding: EdgeInsets.only(left: 29, right: 29, bottom: 5),
        child: iconActionButton(
            context: context,
            buttonColor: 'red',
            icon: Icon(Icons.close),
            text: 'leave drop',
            // order: order,
            // orderCallback: rateOrder,
            isLoading: false,
            callback: dropCallback));
  }

  Widget productDetails() {
    return new Container(
      //padding: const EdgeInsets.all(16.0),
      child: ListView(children: [
        dropMap(widget.drop!, height: 149),
        dropDetails(widget.drop!, view: true, height: 140, viewDropName: true),
        line(),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 23, 0, 10),
            child: Text('Event Description', style: ThemeText.yellowLabel)),
        dropQuotaCompleted(context, widget.drop!,
            showDescription: true, height: 130),
        // line(),
        Padding(padding: EdgeInsets.only(bottom: 130)),
      ]),
    );
  }

  Widget productList() {
    return Padding(
        padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 100),
        child: widget.drop!.dropProducts.length <= 0
            ? Center(child: _isLoading ? Text('') : Text('Nothing found.'))
            : ListView(
                children: widget.drop!.dropProducts.map((DropProduct product) {
                return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: dropProductItem(product));
              }).toList()));
  }

  Widget dropProductItem(DropProduct product) {
    return Card(
        // color: Colors.red,
        //margin: EdgeInsets.all(5),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          // margin: EdgeInsets.all(5),
          // width: 130,
          height: 221, //  if list then the height is 109
          // padding: const EdgeInsets.all(20),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // color: Colors.red,
                height: 114,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(product.name!, style: ThemeText.greenLabel),
                            Text('Php ' + product.price! + '/' + product.unit!,
                                style: ThemeText.yellowLabel)
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 5,
                        // height: double.infinity,
                        child: new LinearPercentIndicator(
                          // width: MediaQuery.of(context).size.width / 1.4,
                          lineHeight: 14.0,
                          percent: product.percentageNumber!,
                          backgroundColor: Color(0XFFDDDDDD),
                          progressColor: Color(0xFF00A652),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        product.quotaText!,
                      ),
                    ),
                    Divider(
                      height: 1,
                    ),
                  ],
                ),
              ),

              Container(
                height: 57,
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ImageStack(
                            imageList: widget.drop!.participantImages,
                            totalCount: widget.drop!.participantImages
                                .length, // If larger than images.length, will show extra empty circle
                            imageRadius: 35, // Radius of each images
                            imageCount:
                                2, // Maximum number of images to be shown in stack
                            imageBorderWidth:
                                0, // Border width around the images
                          ),
                        ],
                      ),
                      Text(' 2 sellers contributed')
                    ],
                  ),
                ),
              ),

              Container(
                color: Colors.green,
                height: 49,
                child: GestureDetector(
                    onTap: () {
                      _navigateAddContribution(context, product);
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => AddContribution(
                      //           mode: 'add',
                      //           drop: widget.drop!,
                      //           product: product,
                      //         )));
                    },
                    child: SizedBox(
                        width: double.infinity,
                        child: Center(
                            child: Text('Contribute Products',
                                style: ThemeText.whiteLabel)))),
              )

              // dropQuotaCompleted(context, drop),
            ],
          ),
        ));
  }

  _navigateAddContribution(
      BuildContext context, DropProduct dropProduct) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddContribution(
                  mode: 'add',
                  drop: widget.drop!,
                  product: dropProduct,
                )));
    print('contribute');

    if (result != null) {
      if (result['result'] == 'success') {
        print('ok success contributed');
        _tabController!.index = result['go_index'];
      }
    }
  }

  Widget contributionList() {
    return Padding(
        padding: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 100),
        child: widget.drop!.productContributions.length <= 0
            ? Center(child: _isLoading ? Text('') : Text('Nothing found.'))
            : ListView(
                children: widget.drop!.productContributions
                    .map((ProductContribution productContribution) {
                return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child:
                        contributionProductItem(context, productContribution));
              }).toList()));
  }

  Widget contributionProductItem(
      BuildContext context, ProductContribution product,
      {bool isSeller = true}) {
    return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          padding: const EdgeInsets.all(0),
          child: Container(
              child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(children: [
                Container(
                  width: 130,
                  height: 109, //  if list then the height is 109
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
              ]),
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('carrots'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              // color: Colors.red,
                              width: MediaQuery.of(context).size.width * .40,
                              height: 15,
                              child: Text('Added ' +
                                  product.qty.toString() +
                                  product.unit!)),
                          GestureDetector(
                              onTap: () {
                                print('tap basket1');
                                //_addBasket(product);

                                if (isSeller) {
                                  // Open edit
                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (context) => AddProduct(
                                  //           mode: 'edit',
                                  //           product: product,
                                  //         )));
                                } else {
                                  // addBasketModal(context, product);
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
                              )),
                        ],
                      ),
                      Text('Added on' + product.dateTime!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              // color: Colors.red,
                              width: MediaQuery.of(context).size.width * .32,
                              height: 15,
                              child: Text('Total')),
                          Text('Php ' + product.total!),
                        ],
                      )
                    ],
                  ))
              // Padding(
              //     padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         SizedBox(
              //           width: MediaQuery.of(context).size.width * .28,
              //           child: Container(
              //               // color: Colors.red,
              //               child: Text(
              //             product.name!,
              //             style: TextStyle(color: Colors.grey),
              //           )),
              //         ),
              //         Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text('Added on: ' + product.unit! + ' sold',
              //                 style:
              //                     TextStyle(color: Colors.grey, fontSize: 12)),
              //             Padding(
              //               padding: EdgeInsets.only(bottom: 5),
              //             ),
              //             SizedBox(
              //               // width: isList ? 80 : 110, // adjust the width
              //               width: MediaQuery.of(context).size.width * .28,
              //               // adjust the width
              //               child: Container(
              //                 // color: Colors.red,
              //                 child: Text('Total: ',
              //                     style: TextStyle(
              //                         color: greenColor,
              //                         fontSize: 12,
              //                         fontWeight: FontWeight.bold)),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ],
              //     )),
              // Padding(
              //     padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       crossAxisAlignment: CrossAxisAlignment.end,
              //       children: [
              //         Text(
              //           'P ' + product.unit!,
              //           style: TextStyle(
              //               color: greenColor, fontWeight: FontWeight.bold),
              //           textAlign: TextAlign.end,
              //         ),
              //         Text(''),
              //         GestureDetector(
              //             onTap: () {
              //               print('tap basket1');
              //               //_addBasket(product);

              //               if (isSeller) {
              //                 // Open edit
              //                 // Navigator.of(context).push(MaterialPageRoute(
              //                 //     builder: (context) => AddProduct(
              //                 //           mode: 'edit',
              //                 //           product: product,
              //                 //         )));
              //               } else {
              //                 // addBasketModal(context, product);
              //               }

              //               // print(product.user!.id);

              //               // print(isSeller.toString());
              //             },
              //             child: SvgPicture.asset(
              //               isSeller
              //                   ? 'assets/images/edit.svg'
              //                   : 'assets/images/cart.svg',
              //               height: 28,
              //               width: 36,
              //               color: iconColor,
              //             ))
              //       ],
              //     )),
            ],
          )),
        ));
  }

  PreferredSizeWidget appBar() {
    return appBarTopWithBack(
      context,
      title: 'Magri Drop',
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: Material(
            // Set the background color of the tab here
            color: Colors.white,
            //elevation: 1,
            shadowColor: Colors.grey,
            child: Container(
                // margin: EdgeInsets.zero,
                padding: EdgeInsets.only(left: 20, right: 20),
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
                ))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appBarTopWithBack(context, isMain: false, title: 'Magri Drop'),
      appBar: appBar(),
      backgroundColor: body_color,
      body: TabBarView(
        controller: _tabController,
        children: [
          productDetails(),
          productList(),
          contributionList(),
        ],
      ),
      bottomNavigationBar:
          _tabController!.index != 0 ? null : SafeArea(child: joinDropButton()),
    );
  }
}
