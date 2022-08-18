import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:magri/models/order.dart';
import 'package:magri/models/order_item.dart';
import 'package:magri/widgets/modals/rate_order_modal.dart';
import 'package:magri/widgets/pages/tabs/view_order.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/colors.dart';
import 'package:magri/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/product.dart';

class MyOrders extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders>
    with SingleTickerProviderStateMixin<MyOrders> {
  bool _isLoading = false;

  TabController? _controller;

  List<Widget> _tabList = [
    Tab(text: 'Pending'),
    Tab(
      child: Text('Confirmed'),
    ),
    Tab(text: 'To Deliver'),
    Tab(text: 'Completed'),
    Tab(text: 'Cancelled'),
  ];

  List<Order> _orders = [];

  List<Order> _new = [];
  List<Order> _confirmed = [];
  List<Order> _delivered = [];
  List<Order> _completed = [];
  List<Order> _cancelled = [];

  List<Product> _vegetables = [];
  List<Product> _fruits = [];
  List<Product> _condiments = [];

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: _tabList.length, vsync: this);

    _controller!.addListener(() {
      setState(() {
        // _selectedIndex = _controller!.index;
      });
      print("Selected Index: " + _controller!.index.toString());
    });

    fetch();
  }

  void fetch() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    fetchOrders().then((dataItems) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (dataItems != null) {
          _new.clear();
          _confirmed.clear();
          _delivered.clear();
          _completed.clear();
          _cancelled.clear();
          dataItems.forEach((item) {
            String stat = Order.fromMap(item).status!;
            if (stat == STATUS_NEW) {
              _new.add(Order.fromMap(item));
            }
            if (stat == STATUS_CONFIRMED) {
              _confirmed.add(Order.fromMap(item));
            }
            if (stat == STATUS_TODELIVER) {
              _delivered.add(Order.fromMap(item));
            }
            if (stat == STATUS_COMPLETED) {
              _completed.add(Order.fromMap(item));
            }
            if (stat == STATUS_CANCELLED) {
              _cancelled.add(Order.fromMap(item));
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

  Future<void> _refreshProducts() async {
    print('pull');
    fetch();
  }

  // void viewOrder() {
  //   print('viewOrder');
  //   Navigator.of(context).push(
  //       MaterialPageRoute(builder: (context) => ViewOrder(order: _seller)));
  // }

  void rateOrder(BuildContext? context, Order? order) {
    print('rateOrder');
    rateOrderModal(context!, order: order);
  }

  Widget actionButton(Order order, OrderItem orderItem) {
    if (order.status == STATUS_NEW ||
        order.status == STATUS_CONFIRMED ||
        order.status == STATUS_TODELIVER) {
      return orderTotalGreen(
          order,
          'Order Total(' +
              orderItem.quantity.toString() +
              orderItem.productUnit! +
              ')');
    }

    if (order.status == STATUS_CANCELLED) {
      return orderTotalGreen(
          order,
          'Order Total(' +
              orderItem.quantity.toString() +
              orderItem.productUnit! +
              ')',
          color: Color(0XFFB1B1B1));
    }

    // If completed and with rating
    if (order.rating != 0.0 || order.rating != 0) {
      return Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: RatingBar.builder(
            initialRating: order.rating,
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
            itemSize: 20,
            onRatingUpdate: (rating) {
              print(rating);
            },
          ));
    }
    return iconActionButton(
        context: context,
        // buttonColor: 'red',
        // icon: Icon(Icons.close),
        text: 'Rate Order',
        order: order,
        orderCallback: rateOrder,
        isLoading: false,
        callback: null);
  }

  _navigateViewOrder(BuildContext context, Order order) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => AddCreditCard(
    //             selectedCardIndex: _selectedCardIndex,
    //             paymayaCustomerId: _paymayaCustomerId,
    //           )),
    // );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewOrder(order)),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        // Refresh orders page and go to cancelled tab
        fetch();
        if (result['status'] == STATUS_CANCELLED) {
          _controller!.animateTo(4);
        } else {
          _controller!.animateTo(3);
        }
      }
    }
  }

  Widget showOrders(List<Order> orders) {
    return _isLoading
        ? spin()
        : RefreshIndicator(
            color: Colors.green[600],
            onRefresh: _refreshProducts,
            child: orders.length == 0
                ? Text('Nothing yet.')
                : Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0.0),
                    child: ListView(
                        children: orders.map((Order order) {
                      return Padding(
                          padding: EdgeInsets.only(bottom: 29),
                          child: showOrder(order));
                    }).toList())));
  }

  Widget showOrder(Order order) {
    if (order.orderItems![0].product == null) {
      return Container();
    }
    Product product = order.orderItems![0].product!; //  Get the first item
    OrderItem orderItem = order.orderItems![0];
    product.qty = order.orderItems![0].quantity!;

    return GestureDetector(
        onTap: () {
          _navigateViewOrder(context, order);
        },
        child: Card(
            elevation: 2,
            child: Container(
              height: 237,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                      child: userAccount(context, order.seller,
                          isProfile: true,
                          putActive: false,
                          messageIcon: true,
                          width: 25,
                          height: 25)),
                  line(1),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 0),
                    child: singleProduct(context, product,
                        priceFontsize: 14, order: order),
                  ),
                  line(1),
                  arrowLinkButton(context,
                      height: 50,
                      color: Colors.white,
                      title: order.statusMessage,
                      titleColor: titleColor(order),
                      callback: null),
                  actionButton(order, orderItem)
                ],
              ),
            )));
  }

  titleColor(Order order) {
    if (order.status == STATUS_COMPLETED) {
      return yellowColor;
    }

    if (order.status == STATUS_CANCELLED) {
      return redColor;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = context.watch<ChangeNotifierUser>().getUser();
    return Scaffold(
      backgroundColor: body_color,
      appBar: appBarTopWithBack(
        context,
        // isMain: false,
        title: 'My Orders',
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
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0XFFFECD4D),
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.label,
                    onTap: (index) {
                      // Should not used it as it only called when tab options are clicked,
                      // not when user swapped
                    },
                    controller: _controller,
                    tabs: _tabList,
                  ))),
        ),
      ),
      body: new Container(
        padding: const EdgeInsets.all(28.0),
        child: Stack(children: [
          TabBarView(
            controller: _controller,
            children: [
              showOrders(_new),
              showOrders(_confirmed),
              showOrders(_delivered),
              showOrders(_completed),
              showOrders(_cancelled),
            ],
          ),
        ]),
      ),
    );
  }
}
