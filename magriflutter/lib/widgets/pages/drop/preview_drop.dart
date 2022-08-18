import 'package:flutter/material.dart';
import 'package:magri/models/drop.dart';
import 'package:magri/widgets/pages/drop/drop_details.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/account.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/widgets/partials/drop_item.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class PreViewDrop extends StatefulWidget {
  final Drop drop;
  PreViewDrop(this.drop);
  @override
  State<StatefulWidget> createState() => new _ViewDropState();
}

class _ViewDropState extends State<PreViewDrop> {
  Drop? _drop;

  User? _seller;

  bool _showBuyNow = false;

  @override
  void initState() {
    super.initState();

    currentFile('preview_drop.dart');

    setState(() {
      _drop = widget.drop;
    });
  }

  @override
  void dispose() {
    super.dispose();
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

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DropDetails(drop: widget.drop)));
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

  Widget details() {
    return new Container(
      //padding: const EdgeInsets.all(16.0),
      child: ListView(children: [
        dropMap(widget.drop, height: 149),
        dropDetails(widget.drop, view: true, height: 140, viewDropName: true),
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
    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: 'Magri Drop'),
      backgroundColor: body_color,
      body: details(),
      bottomNavigationBar: SafeArea(child: joinDropButton()),
    );
  }
}
