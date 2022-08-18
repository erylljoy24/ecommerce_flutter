import 'package:flutter/material.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/util/colors.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

import 'top_method.dart';

class TopUp extends StatefulWidget {
  final String? returnTo; // return to page
  TopUp({this.returnTo});
  @override
  State<StatefulWidget> createState() => new _TopUpState();
}

class _TopUpState extends State<TopUp> {
  bool isLoading = false;
  double progress = 0.2;

  List<String> _amounts = ['1000', '2000', '5000'];
  List<bool> _amountSelected = [false, false, false];

  TextEditingController _amountController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget amountBox(String amount, int index) {
    return GestureDetector(
        onTap: () {
          print(amount);
          setState(() {
            _amountSelected[0] = false;
            _amountSelected[1] = false;
            _amountSelected[2] = false;
            _amountSelected[index] = true;
          });
          _amountController.text = amount;
        },
        child: SizedBox(
            width: 100,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _amountSelected[index]
                            ? Colors.blueAccent
                            : Colors.grey)),
                padding: EdgeInsets.all(10),
                child: Center(child: Text('P' + amount)))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: body_color,
          title: Text(
            'Enter Amount',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          leading: popArrow(context),
          bottomOpacity: 0.0,
        ),
        backgroundColor: body_color,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Under development. UI needed.',
                style: TextStyle(color: Colors.red),
              ),
              Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
              Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    amountBox('1000', 0),
                    amountBox('2000', 1),
                    amountBox('5000', 2),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
              Text('PHP'),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10.0, 30.0, 16.0),
                child: TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  controller: _amountController,
                  autofocus: true,
                  inputFormatters: [
                    ThousandsFormatter(
                        allowFraction: true) // with space. check after dot(.)
                  ],
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.right,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    labelText: 'Enter Amount',
                    labelStyle: new TextStyle(color: Colors.black),
                    //hintText: '1,000.00',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      borderSide: BorderSide(
                        color: inputBorderColor,
                        //width: 2.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[100]!),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Amount is required!';
                    }
                    return null;
                  },
                ),
              ),
              new ElevatedButton(
                style: ElevatedButton.styleFrom(
                  //elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.green[700]!)),
                  primary: Colors.white,
                ),
                child: new Text('Continue',
                    style: new TextStyle(fontSize: 12.0, color: Colors.black)),
                onPressed: () {
                  if (_amountController.text == '' ||
                      _amountController.text == '0') {
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TopUpMethod(
                          returnTo: widget.returnTo,
                          topUpAmount: double.parse(
                              _amountController.text.replaceAll(',', '')))));
                },
              )
            ],
          ),
        ));
  }
}
