import 'package:flutter/material.dart';
import 'package:magri/widgets/pages/orders/confirm_order.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'take_selfie_photo.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class Verification extends StatefulWidget {
  final User user;
  Verification(this.user);
  @override
  State<StatefulWidget> createState() => new _VerificationState();
}

class _VerificationState extends State<Verification> {
  bool isLoading = false;
  double progress = 0.2;

  List<String> _images = [];

  String _title = 'Verification';

  String _howToget = 'How to get Verified';

  String _stepOneLabel = '1. Take a Photo of your ID';

  Color _circleColor = Colors.transparent;

  String _id = 'id.png';
  String _selfie = 'selfie.png';
  String _confirm = 'confirm.png';

  @override
  void initState() {
    super.initState();

    if (widget.user.type == User.SELLER_TYPE) {
      setState(() {
        _title = 'Selling Verification';
        _howToget = 'How to be a Verified Seller';
        _stepOneLabel = '1. Take 2 Valid ID photo of you';

        _id = 'seller_id.png';
        _selfie = 'seller_selfie.png';
        _confirm = 'seller_confirm.png';

        // _circleColor = Color(0XFF3FBC7D);
      });
    }

    getUser();
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

  void productCallback(BuildContext? context, Product? product) {
    print('callback view product' + product!.qty.toString());
    if (product.qty > 0) {
      Navigator.of(context!).push(MaterialPageRoute(
          builder: (context) => ConfirmOrder(product: product)));
    }
  }

  void callback() {
    // if (product.qty > 0) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => TakeSelfiePhoto(widget.user)));
    // }
  }

  Widget verifyButton() {
    return Padding(
        padding: EdgeInsets.only(left: 29, right: 29, bottom: 5),
        child: iconActionButton(
            context: context,
            buttonColor: 'green',
            // icon: Icon(Icons.close),
            text: 'verified',
            // order: order,
            // orderCallback: rateOrder,
            isLoading: false,
            callback: callback));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: _title),
      backgroundColor: body_color,
      body: new Container(
        child: ListView(children: [
          // Stack(children: [
          //   showSliders(),
          //   Positioned(child: showController(), right: 30, top: 40),
          // ]),
          Padding(
              padding: EdgeInsets.fromLTRB(0, 23, 0, 10),
              child:
                  Center(child: Text(_howToget, style: ThemeText.greenLabel))),

          CircleAvatar(
            backgroundColor: _circleColor,
            // backgroundImage: CachedNetworkImageProvider(user.image!),
            child: Image.asset(
              'assets/images/' + _id,
            ),
            radius: 57.5,
          ),

          Padding(
            padding: EdgeInsets.only(left: 0, bottom: 10, right: 0, top: 7),
            child:
                Center(child: Text(_stepOneLabel, style: ThemeText.greenLabel)),
          ),

          CircleAvatar(
            backgroundColor: _circleColor,
            // backgroundImage: CachedNetworkImageProvider(user.image!),
            child: Image.asset(
              'assets/images/' + _selfie,
            ),
            radius: 57.5,
          ),
          Padding(
            padding: EdgeInsets.only(left: 0, bottom: 10, right: 0, top: 7),
            child: Center(
                child: Text('2. Take a Selfie', style: ThemeText.greenLabel)),
          ),
          CircleAvatar(
            backgroundColor: _circleColor,
            // backgroundImage: CachedNetworkImageProvider(user.image!),
            child: Image.asset(
              'assets/images/' + _confirm,
            ),
            radius: 57.5,
          ),
          Padding(
            padding: EdgeInsets.only(left: 0, bottom: 10, right: 0, top: 7),
            child: Center(
                child: Text('3. Confirm Information',
                    style: ThemeText.greenLabel)),
          ),

          // Padding(padding: EdgeInsets.only(bottom: 130)),
        ]),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: verifyButton(),
      bottomNavigationBar: SafeArea(child: verifyButton()),
    );
  }
}
