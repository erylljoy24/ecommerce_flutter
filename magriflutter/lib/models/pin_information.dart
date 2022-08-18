import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final String columnId = 'id';
final String columnName = 'name';
final String columnMinutes = 'minutes';
final String columnAmount = 'amount';
final String columnChecked = 'checked';

class PinInformation {
  String? pinPath;
  String? avatarPath;
  LatLng? location;
  String? locationName;
  Color? labelColor;

  PinInformation(
      {this.pinPath,
      this.avatarPath,
      this.location,
      this.locationName,
      this.labelColor});

  // Notif.map(dynamic obj) {
  //   this.id = obj['id'];
  //   this.name = obj['name'];
  //   this.cost = obj['cost'];
  //   this.price = obj['price'];
  //   this.qty = obj['qty'];
  // }

  // Map<String, dynamic> toMap() {
  //   var map = <String, dynamic>{
  //     columnName: name,
  //     columnCost: cost,
  //     columnPrice: price,
  //     columnQty: qty,
  //     columnVersion: version,
  //   };
  //   if (id != null) {
  //     map[columnId] = id;
  //     map[columnRemoteItemId] = remoteItemId;
  //   }
  //   return map;
  // }

  // PinInformation.fromMap(Map<String, dynamic> map) {
  //   id = map[columnId];
  //   name = map[columnName];
  //   minutes = map[columnMinutes];
  //   amount = map[columnAmount];
  //   checked = map[columnChecked];
  // }

  // // From json
  // Price.fromJson(Map<String, dynamic> json)
  //     : id = json[columnId],
  //       name = json[columnName],
  //       minutes = json[columnMinutes],
  //       amount = json[columnAmount],
  //       checked = json[columnChecked];

}
