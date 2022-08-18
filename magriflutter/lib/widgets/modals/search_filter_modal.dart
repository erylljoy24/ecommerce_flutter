import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:magri/controllers/FilterController.dart';
import 'package:magri/util/helper.dart';
import 'package:magri/widgets/partials/buttons.dart';

final FilterController filterController = Get.put(FilterController());

void distanceFilterModal(BuildContext context) {
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
              height: 280,
              color: Colors.white,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 16, left: 37, right: 37),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            popArrow(context, color: Colors.grey),
                            Text(
                              'Distance',
                              style: TextStyle(fontSize: 22),
                            ),
                            // popArrow(context, color: Colors.grey),
                            Text(
                              '',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )),
                    // Spacer(),
                    line(2),
                    distanceForm(),
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
                                    callback: priceCallback),
                              ],
                            )))
                  ],
                ),
              ),
            ));
      });
    },
  );

  future.then((void value) => _closeDistanceModal(value));
}

void _closeDistanceModal(void value) {
  print('modal _closePriceModal');
}

Widget distanceForm() {
  return Container(
    padding: EdgeInsets.only(left: 34, right: 34),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
          child: TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.number,
            autofocus: false,
            // inputFormatters: [ThousandsFormatter()],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: '1000',
              hintStyle: new TextStyle(color: Colors.grey[300]),
              labelText: 'Kilometer',
              labelStyle: new TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  //width: 2.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[100]!),
              ),
            ),
            onChanged: (value) {
              filterController.setDistance(0.0);
              if (value != '') {
                filterController.setDistance(double.parse(value));
              }
            },
            validator: (value) {
              // if (value!.isEmpty) {
              //   return 'Stocks is required!';
              // }

              return null;
            },
            initialValue: filterController.distance.value.toString(),
          ),
        ),
      ],
    ),
  );
}

void priceFilterModal(BuildContext context) {
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
              height: 580,
              color: Colors.white,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 16, left: 37, right: 37),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            popArrow(context, color: Colors.grey),
                            Text(
                              'Price',
                              style: TextStyle(fontSize: 22),
                            ),
                            // popArrow(context, color: Colors.grey),
                            Text(
                              '',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )),
                    // Spacer(),
                    line(2),
                    priceForm(),
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
                                    callback: priceCallback),
                              ],
                            )))
                  ],
                ),
              ),
            ));
      });
    },
  );

  future.then((void value) => _closePriceModal(value));
}

void _closePriceModal(void value) {
  print('modal _closePriceModal');
}

Widget priceForm() {
  return Container(
    padding: EdgeInsets.only(left: 30, right: 30),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
          child: TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.number,
            // controller: stocksController,
            autofocus: false,
            // inputFormatters: [ThousandsFormatter()],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: '1000',
              hintStyle: new TextStyle(color: Colors.grey[300]),
              labelText: 'Min price (Php)',
              labelStyle: new TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  //width: 2.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[100]!),
              ),
            ),
            onChanged: (value) {
              // filterController.priceMin.value = double.parse(value);
              filterController.setPriceMin(double.parse(value));
            },
            validator: (value) {
              // if (value!.isEmpty) {
              //   return 'Stocks is required!';
              // }

              return null;
            },
          ),
        ),
        Text('-'),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10.0, 0.0, 0.0),
          child: TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.number,
            // controller: stocksController,
            autofocus: false,
            // inputFormatters: [ThousandsFormatter()],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: '1000',
              hintStyle: new TextStyle(color: Colors.grey[300]),
              labelText: 'Max price (Php)',
              labelStyle: new TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2.0),
                borderSide: BorderSide(
                  color: Colors.transparent,
                  //width: 2.0,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[100]!),
              ),
            ),
            onChanged: (value) {
              // filterController.priceMax.value = double.parse(value);
              filterController.setPriceMax(double.parse(value));
            },
            validator: (value) {
              // if (value!.isEmpty) {
              //   return 'Stocks is required!';
              // }

              return null;
            },
          ),
        ),
        ListTile(
          onTap: () {
            setPrice(0.0, 500.00);
          },
          leading: Icon(Icons.check),
          title: Text('Php 0 - Php 500'),
          // subtitle: Text('(All)'),
        ),
        ListTile(
          onTap: () {
            setPrice(501.0, 1000.00);
          },
          leading: Icon(Icons.check),
          title: Text('Php 501 - Php 1000'),
          // subtitle: Text('(All)'),
        ),
        ListTile(
          onTap: () {
            setPrice(1001.0, 1500.00);
          },
          leading: Icon(Icons.check),
          title: Text('Php 1001 - Php 1500'),
          // subtitle: Text('(All)'),
        ),
        ListTile(
          onTap: () {
            setPrice(1501.0, 0.00);
          },
          leading: Icon(Icons.check),
          title: Text('Php > 1500'),
          // subtitle: Text('(All)'),
        ),
      ],
    ),
  );
}

void setPrice(double priceMin, double priceMax) {
  filterController.setPrice(priceMin, priceMax);

  Get.back();
}

void priceCallback() {
  print('priceCallback');
  Get.back();
}

void rateFilterModal(BuildContext context) {
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
              height: 280,
              color: Colors.white,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 16, left: 37, right: 37),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            popArrow(context, color: Colors.grey),
                            Text(
                              'Rate',
                              style: TextStyle(fontSize: 22),
                            ),
                            // popArrow(context, color: Colors.grey),
                            Text(
                              '',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )),
                    // Spacer(),
                    line(2),
                    rateForm(),
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
                                    callback: priceCallback),
                              ],
                            )))
                  ],
                ),
              ),
            ));
      });
    },
  );

  future.then((void value) => _closeRateModal(value));
}

void _closeRateModal(void value) {
  print('modal _closeRateeModal');
}

Widget rateForm() {
  return Container(
    padding: EdgeInsets.only(left: 37, right: 37, top: 37),
    child: Center(
      child: RatingBar.builder(
        initialRating: filterController.ratings.value,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          filterController.setRate(rating);
          // print(rating);
        },
      ),
    ),
  );
}
