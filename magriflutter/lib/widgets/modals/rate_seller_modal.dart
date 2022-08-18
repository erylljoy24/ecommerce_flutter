import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:magri/models/user.dart';
import 'package:magri/widgets/partials/buttons.dart';
import 'package:magri/util/colors.dart';

void rateSellerModal(BuildContext context, User seller) {
  showModalBottomSheet<void>(
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
              height: 358,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 10.5)),
                    Text(
                      'Rate Seller',
                      style: TextStyle(fontSize: 22),
                    ),
                    RatingBar.builder(
                      initialRating: 4.5,
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
                        seller.ratings = rating.toString();
                        print(rating);
                      },
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(29.0, 10.0, 29.0, 10.0),
                      child: TextFormField(
                        maxLines: 3,
                        keyboardType: TextInputType.text,
                        // controller: descriptionController,
                        autofocus: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              '[a-zA-Z0-9!. ]')), // with space. check after dot(.)
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: new InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          labelText: "Enter review here",
                          labelStyle: new TextStyle(color: Colors.black),
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
                        onChanged: (value) {
                          seller.ratingMessage = value;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Description is required!';
                          }

                          if (value.trim() == '') {
                            return 'Description is required!';
                          }
                          return null;
                        },
                      ),
                    ),
                    SafeArea(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconActionButton(
                            context: context,
                            text: 'submit rating',
                            // product: product,
                            seller: seller,
                            userCallback: userCallback,
                            callback: callback),
                      ],
                    ))
                  ],
                ),
              ),
            ));
      });
    },
  );
}

void userCallback(BuildContext? context, User? user) {
  print('userCallback');
  rateSeller(
          user!.id!.toString(), double.parse(user.ratings), user.ratingMessage)
      .then((value) {
    Navigator.pop(context!);
  });
}

void callback() {
  print('callback123');
}
