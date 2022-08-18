// class ProvinceCityModal extends StatefulWidget {
//   final User user;
//   ProvinceCityModal(this.user);

//   @override
//   _ProvinceCityModalState createState() => _ProvinceCityModalState();
// }

// class _ProvinceCityModalState extends State<ProvinceCityModal> {
//   Widget build(BuildContext context) {
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       Text('111'),
//       Icon(Icons.edit),
//     ]);

//   }
// }

// void provinceCityModal(BuildContext context, Address address) {
//   showModalBottomSheet<void>(
//     context: context,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(10.0),
//     ),
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setModalState) {
//         // final quantityController =
//         //     TextEditingController(text: quantity.toString());
//         return Padding(
//             padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: Container(
//               height: 400,
//               padding: EdgeInsets.all(20.0),
//               //color: Colors.grey[100],
//               child: Container(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Row(
//                       children: [
//                         Spacer(),
//                         new GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Icon(Icons.close)),
//                       ],
//                     ),
//                     // Spacer(),
//                     // Text('Quantity'),
//                     // Spacer(),
//                   ],
//                 ),
//               ),
//             ));
//       });
//     },
//   );
// }
