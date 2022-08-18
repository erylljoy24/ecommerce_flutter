import 'package:flutter/material.dart';
import 'package:magri/models/drop.dart';
import 'package:magri/models/product.dart';
import 'package:magri/util/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:magri/widgets/pages/drop/preview_drop.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../Constants.dart';

Widget singleDropLandScape(BuildContext context, Drop drop, bool isLoading,
    {Function(Product)? productCallback,
    bool isList = false,
    bool isSeller = false}) {
  if (isList) {
    return Card(
        // color: Colors.red,
        //margin: EdgeInsets.all(5),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          width: 130,
          height: isList ? 312 : 150, //  if list then the height is 109
          padding: const EdgeInsets.all(0),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              dropMap(drop),
              dropDetails(drop),
              Divider(
                height: 1,
              ),
              dropQuotaCompleted(context, drop),
            ],
          ),
        ));
  }

  // If not list(sliders)
  return Card(
      // color: Colors.red,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        // width: 130,
        height: 212,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            dropDetails(drop),
            Divider(
              height: 1,
            ),
            dropQuotaCompleted(context, drop),
          ],
        ),
      ));
}

Widget dropMap(Drop drop, {double? height = 109}) {
  return Container(
    height: height,
    decoration: BoxDecoration(
      color: Colors.blue,
      // borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(5),
      //     //topRight: Radius.circular(10),
      //     bottomLeft: Radius.circular(5)),
      image: DecorationImage(
        fit: BoxFit.fill,
        image: CachedNetworkImageProvider(
            'https://maps.googleapis.com/maps/api/staticmap?center=' +
                drop.latitude!.toString() +
                ',' +
                drop.longitude!.toString() +
                '&zoom=13&size=300x109&maptype=roadmap%20&markers=color:red%7Clabel:D%7C' +
                drop.latitude!.toString() +
                ',' +
                drop.longitude!.toString() +
                '%20&key=' +
                GOOGLE_MAPS_API_KEY),
      ),
    ),
    // https://maps.googleapis.com/maps/api/staticmap?center=Brooklyn+Bridge,New+York,NY&zoom=13&size=600x300&maptype=roadmap%20&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318%20&markers=color:red%7Clabel:C%7C40.718217,-73.998284%20&key=AIzaSyCCgaVlDWys8gyYOxfTJUwpM3zIoMQfQ24
  );
}

Widget dropDetails(Drop drop,
    {bool view = false, double? height = 109, bool viewDropName = false}) {
  return Container(
    padding: EdgeInsets.all(20),
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      // borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(5),
      //     //topRight: Radius.circular(10),
      //     bottomLeft: Radius.circular(5)),
      // image: DecorationImage(
      //   fit: BoxFit.fill,
      //   image: CachedNetworkImageProvider(drop.imageUrl!),
      // ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          drop.name,
          style: TextStyle(fontSize: view ? 22 : 12, color: Color(0xFF00A652)),
        ),
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.green[700],
            ),
            Padding(padding: EdgeInsets.only(right: 10)),
            Text(
              'June 1, 2021 - June 3, 2021',
              style: TextStyle(color: Color(0xFF00A652)),
            )
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.map,
              color: Colors.green[700],
            ),
            Padding(padding: EdgeInsets.only(right: 10)),
            Text(
              drop.address,
              style: TextStyle(color: Color(0xFF00A652)),
            )
          ],
        ),
        viewDropName
            ? Row(
                children: [
                  Icon(
                    Icons.map,
                    color: Colors.green[700],
                  ),
                  Padding(padding: EdgeInsets.only(right: 10)),
                  Text(
                    drop.dropByName!,
                    style: TextStyle(color: Color(0xFF00A652)),
                  )
                ],
              )
            : Container(),
        // Divider(),
      ],
    ),
  );
}

Widget dropQuotaCompleted(BuildContext context, Drop drop,
    {bool showDescription = false, double? height = 93}) {
  return Container(
    padding: EdgeInsets.all(20),
    height: height,
    decoration: BoxDecoration(
        // color: Colors.red,
        // borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(5),
        //     //topRight: Radius.circular(10),
        //     bottomLeft: Radius.circular(5)),
        // image: DecorationImage(
        //   fit: BoxFit.fill,
        //   image: CachedNetworkImageProvider(drop.imageUrl!),
        // ),
        ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        showDescription
            ? Text(drop.description)
            : Container(
                height: 0,
              ),
        SizedBox(
          width: double.infinity,
          height: 5,
          // height: double.infinity,
          child: new LinearPercentIndicator(
            // width: MediaQuery.of(context).size.width / 1.4,
            lineHeight: 14.0,
            percent: drop.percentageNumber!,
            backgroundColor: Color(0XFFDDDDDD),
            progressColor: Color(0xFF00A652),
          ),
        ),
        Text('50 kg out of 150 kg Quota Completed'),
      ],
    ),
  );
}

Widget dropRating(Drop drop) {
  return ButtonTheme(
      minWidth: 46.0,
      height: 29.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          textStyle: TextStyle(color: Colors.black),
          primary: Colors.yellow[700],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: yellowLabelRatingColor)),
        ),
        onPressed: () {
          // Respond to button press
        },
        child: Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.white,
              size: 15,
            ),
            // Text(drop.ratings!, style: TextStyle(color: Colors.white)),
          ],
        ),
      ));
}

class DropItem extends StatefulWidget {
  final Drop? drop;
  final bool isList;
  final bool isSeller;

  DropItem({this.drop, this.isList = false, this.isSeller = false});

  @override
  _MapProductsState createState() => _MapProductsState();
}

class _MapProductsState extends State<DropItem> {
  bool _isLoading = false;
  Future<bool> favoriteProduct(Product _product) async {
    setState(() {
      _isLoading = true;
    });

    setState(() {
      _isLoading = false;
    });
    return true;
  }

  GestureDetector dropLandscapeCard(BuildContext context, Drop drop,
          {bool isList = false, bool isSeller = false}) =>
      GestureDetector(
        onTap: () {
          print('tap drop landscape...');
          // Navigator.of(context).push(
          //     new MyCustomRoute(builder: (context) => ViewProduct(product)));
          if (isSeller) {
            // Open edit
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (context) => AddProduct(
            //           mode: 'edit',
            //           product: drop,
            //         )));
          } else {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PreViewDrop(drop)));
          }
        },
        child: singleDropLandScape(context, drop, _isLoading,
            // productCallback: favoriteProduct,
            isList: isList,
            isSeller: isSeller),
      );

  Widget build(BuildContext context) {
    return dropLandscapeCard(context, widget.drop!,
        isList: widget.isList, isSeller: widget.isSeller);
  }
}
