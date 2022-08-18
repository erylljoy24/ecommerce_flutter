import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magri/models/drop.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/drop_item.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class ViewDrop extends StatefulWidget {
  final Drop drop;
  ViewDrop(this.drop);
  @override
  State<StatefulWidget> createState() => new _ViewProductState();
}

class _ViewProductState extends State<ViewDrop> {
  bool isLoading = false;
  double progress = 0.2;

  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;

  CarouselController buttonCarouselController = CarouselController();

  int _current = 0;

  Color? _favoriteColor = Colors.grey;

  List<String> _images = [];

  Drop? _drop;

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
      _drop = widget.drop;
      // _product!.qty = 1;
      // _images = _product!.images;
      // _seller = _product!.user;
    });

    // Store to recently viewed
    // view(_product);
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

    // Cant buy on own product
    // if (_showBuyNow == false) {
    //   return;
    // }
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
            buttonColor: 'green',
            // icon: Icon(Icons.close),
            text: 'join drop',
            // order: order,
            // orderCallback: rateOrder,
            isLoading: false,
            callback: dropCallback));
  }

  Widget productDetails() {
    return new Container(
      //padding: const EdgeInsets.all(16.0),
      child: ListView(children: [
        dropMap(widget.drop, height: 149),
        dropDetails(widget.drop, view: true, height: 135),
        line(),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 23, 0, 10),
            child: Text('Event Description', style: ThemeText.yellowLabel)),
        dropQuotaCompleted(context, widget.drop,
            showDescription: true, height: 130),
        line(),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 0, 10),
            child: Text('Product Preview', style: ThemeText.yellowLabel)),
        Padding(
            padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
            child: userAccount(context, _seller,
                putActive: false, messageIcon: true)),
        line(),
        Padding(padding: EdgeInsets.only(bottom: 130)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var user = context.watch<ChangeNotifierUser>();

    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: 'Magri Drop'),
      backgroundColor: body_color,
      body: productDetails(),
      bottomNavigationBar: SafeArea(child: joinDropButton()),
    );
  }
}
