import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pusher_client/flutter_pusher.dart';
import 'package:flutter_svg/svg.dart';
import 'package:magri/models/changenotifiers/change_notifier_chat_order.dart';
import 'package:magri/models/changenotifiers/changenotifierinbox.dart';
import 'package:magri/models/inbox.dart';
import 'package:magri/models/order.dart';
import 'package:magri/widgets/partials/appbar.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/chat_message.dart';
import 'package:magri/models/order_item.dart';
import 'package:magri/models/product.dart';
import 'package:magri/models/user.dart';
import 'package:magri/util/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:pusher_client/pusher_client.dart';
// import 'package:laravel_echo/laravel_echo.dart';
// import 'package:flutter_pusher_client/flutter_pusher.dart';
// import 'package:flutter_pusher/pusher.dart';
// import 'package:flutter_laravel_echo/flutter_laravel_echo.dart';

import '../../../Constants.dart';
import '../checkout.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

// PusherOptions options = PusherOptions(
//   host: '10.0.2.2',
//   port: 6001,
//   encrypted: false,
// );

// FlutterPusher pusher = FlutterPusher('app', options, enableLogging: true);

// Echo echo = new Echo({
//   'broadcaster': 'pusher',
//   'client': pusher,
//   // 'auth': {
//   //   'headers': {
//   //       'Authorization': 'Bearer $token'
//   //   }
//   // }
// });

// echo.channel('public-channel').listen('PublicEvent', (e) {
//   print(e);
// });

// socket.on('connect', (_) => print('connect'));
// socket.on('disconnect', (_) => print('disconnect'));

class ViewChat extends StatefulWidget {
  final User? user;
  final OrderItem? orderItem;
  final Inbox? inbox;
  final int? inboxIndex;

  ViewChat({required this.user, this.orderItem, this.inbox, this.inboxIndex});
  @override
  State<StatefulWidget> createState() => new _ViewChatState();
}

class _ViewChatState extends State<ViewChat> {
  final _messageController = TextEditingController();

  bool _isLoading = false;

  User? _seller;
  OrderItem? _orderItem;

  bool _isNew = false;
  List<Widget> _chatItems = [];

  List<OrderItem?> _ordersItems = [];

  List<ChatMessage> _userMessages = [];

  FocusNode? _messageField;

  bool _hasMessage = false;

  String _cancelOrderText = 'Cancel Order';

  String _areYouSureMessage = 'Are you sure you want to cancel?';

  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.org'),
  );

  // Event lastEvent;
  String? lastConnectionState;
  Channel? channel;
  FlutterPusher? _pusher;

  var channelController = TextEditingController(text: "chat");
  var eventController = TextEditingController(text: "messages");
  var triggerController = TextEditingController(text: "client-trigger");

  // https://nhancv.medium.com/flutter-pusher-with-laravel-echo-7fa7d7929517
  Future<void> initPusher() async {
    final SharedPreferences prefs = await _prefs;
    String? userId = await prefs.getString('userId');

    PusherOptions options = PusherOptions(
      //   host: 'example.com',
      // wsPort: 6001, //  for self hosted pusher later
      // auth: PusherAuth(
      //   'https://magri.isles.info/broadcasting/auth',
      //   headers: {'Authorization': 'Bearer ' + token},
      // ),
      cluster: PUSHER_CLUSTER,
      encrypted: PUSHER_ENCRYPTED,
    );

    setState(() {
      // _pusher = FlutterPusher('6fafd80ee270a8412b67', options,
      //     enableLogging: true,
      //     onConnectionStateChange: (ConnectionStateChange x) async {
      //       print(x.currentState);
      //     },
      //     onError: (ConnectionError y) => {print(y.message)});

      _pusher = FlutterPusher(PUSHER_APP_KEY, options, enableLogging: true,
          onConnectionStateChange: (ConnectionStateChange? x) {
        print(x!.currentState);
      }, onError: onConnectionError);

      print('subscribe: chat_' + userId!);

      // If user receive new message
      _pusher!.subscribe('chat_' + userId).bind('messages', (event) {
        var map = HashMap.from(event);
        print(map['messages']);
        print(map['from']);
        print(map['type']);

        setState(() {
          _isNew = true;
          // Add at the beginning
          if (map['type'] == TYPE_ORDER) {
            _chatItems.insert(
                0,
                showConfirmReject(OrderItem(
                    map['order_item']['order_id'].toString(),
                    map['order_item']['order_id'],
                    Product.fromMap(map['product']),
                    map['order_item']['quantity'],
                    map['order_item']['total'])));

            Provider.of<ChangeNotifierChatOrder>(context, listen: false)
                .setOrderStatus(map['order_item']['order_id'], STATUS_PENDING);
          } else if (map['type'] == TYPE_CONFIRM_ORDER) {
            // Send confirmation message
            _chatItems.insert(0, textMessageFromOther(map['messages']));
            // _chatItems.insert(
            //     0,
            //     selectPaymentMethod(
            //         OrderItem.fromMap(map['order']['orders_items'][0])));
          } else if (map['type'] == 'cancel_order') {
            // Update the UI
            //print('map' + map['order_id'].toString());
            Provider.of<ChangeNotifierChatOrder>(context, listen: false)
                .setOrderStatus(map['order_id'], STATUS_CANCELLED);
            _chatItems.insert(0, textMessageFromOther(map['messages']));
          } else {
            _chatItems.insert(0, textMessageFromOther(map['messages']));

            // This is for incoming messages
            if (widget.inbox != null) {
              Inbox inbox = widget.inbox!;
              inbox.messages = map['messages'];

              // Change inbox position to the top
              Provider.of<ChangeNotifierInbox>(context, listen: false)
                  .sortInbox(inbox, widget.inboxIndex!);
            }
          }
        });
      });
    });
  }

  void onConnectionError(ConnectionError? error) {
    print(error!.message);
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLoading = true;
      _seller = widget.user;
      _orderItem = widget.orderItem;
      print(_seller!.reviews);
    });

    fetchUserMessages();

    _messageField = FocusNode();

    _messageController.addListener(_messageChanged);

    //print('Item qty: ' + widget.orderItem.quantity.toString());

    initPusher();

    // if (_orderItem != null) {
    //   processSendOrder(_orderItem);
    // }
  }

  void setChatItems() {
    setState(() {
      if (_isNew == false) {
        _chatItems.clear();

        // if (_orderItem != null) {
        //   _chatItems.insert(0, showOrder(_orderItem));
        //   _chatItems.insert(0, selectPaymentMethod(_orderItem));
        // }

        // print('processSendOrder===== SET');
        // _chatItems.insert(0, showConfirmReject(_orderItem));

        // // Confirmed
        // _chatItems.insert(0, showConfirmReject(_orderItem, true));

        //_chatItems.insert(0, selectPaymentMethod());
        //print('clear');
      }

      // _chatItems.add(textMessageFromOther());
      // _chatItems.add(textMessageFromMe());
    });
  }

  void fetchUserMessages() {
    fetchMessagesByUser(widget.user!.id!).then((dataItems) {
      if (!mounted) {
        return;
      }
      if (dataItems == null) {
        return;
      }
      setState(() {
        _isNew = true;
        _isLoading = true;

        if (dataItems.length > 0) {
          // Get the ID of last message
          print(dataItems.last['id']);
          dataItems.forEach((item) {
            ChatMessage chatMessage = ChatMessage.fromMap(item);
            _userMessages.add(chatMessage);

            // Add to screen if possible
            if (chatMessage.position == 'left') {
              if (chatMessage.type == TYPE_TEXT ||
                  chatMessage.type == TYPE_CONFIRM_ORDER) {
                _chatItems.insert(
                    0, textMessageFromOther(chatMessage.messages!));
              }
              if (chatMessage.type == TYPE_SHOW_PAYMENT_METHOD) {
                _chatItems.insert(
                    0, selectPaymentMethod(chatMessage.orderItem));
              }
              // if (chatMessage.type == TYPE_ORDER) {
              //   _chatItems.insert(0, showConfirmReject(chatMessage.orderItem));
              //   Provider.of<ChangeNotifierChatOrder>(context, listen: false)
              //       .setOrderStatus(chatMessage.orderItem!.orderId,
              //           chatMessage.orderItem!.status);
              // }
            } else {
              if (chatMessage.type == TYPE_ORDER) {
                _chatItems.insert(0, showOrder(chatMessage.orderItem));
              } else {
                _chatItems.insert(0, textMessageFromMe(chatMessage.messages!));
              }
            }
          });
        }
        _isLoading = false;
        //_chatItems.insert(0, confirmChangeStatus('orderId'));
      });

      if (_orderItem != null) {
        _chatItems.insert(0, showOrder(_orderItem));
        _chatItems.insert(0, selectPaymentMethod(_orderItem));
        processSendOrder(_orderItem);
      }

      // if (_orderItem != null) {
      //   //processSendOrder(_orderItem);
      //   //print('processSendOrder');
      // }
    });
  }

  void processSendOrder(OrderItem? orderItem) async {
    setState(() {
      _ordersItems.add(orderItem);
      _orderItem!.orderId = orderItem!.orderId;
      _orderItem!.orderNumber = orderItem.orderNumber;
      Provider.of<ChangeNotifierChatOrder>(context, listen: false)
          .setOrderStatus(_orderItem!.orderId, STATUS_PENDING);
    });
  }

  // void processSendOrder(OrderItem orderItem) async {
  //   // int orderId = await sendOrder(orderItem);
  //   var order = await sendOrder(orderItem);

  //   if (order['id'] != 0) {
  //     print('orderId:' + order['id'].toString());
  //     setState(() {
  //       _ordersItems.add(orderItem);
  //       _orderItem.orderId = order['id'];
  //       _orderItem.orderNumber = order['number'];
  //       Provider.of<ChangeNotifierChatOrder>(context, listen: false)
  //           .setOrderStatus(_orderItem.orderId, STATUS_PENDING);
  //     });
  //   }
  // }

  @override
  void dispose() {
    _messageField!.dispose();
    _pusher!.disconnect();
    print('dispose');
    _messageController.dispose();
    super.dispose();
  }

  _messageChanged() {
    if (_messageController.text.isEmpty) {
      setState(() {
        _hasMessage = false;
      });
    } else {
      setState(() {
        _hasMessage = true;
      });
    }
  }

  Widget showOrder(OrderItem? orderItem,
      [String position = 'right', bool isConfirmed = false]) {
    if (orderItem == null) {
      return Container();
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
        margin: EdgeInsets.only(top: 10, right: 10),
        padding: EdgeInsets.all(5),
        width: 230.0,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green[700],
          borderRadius: BorderRadius.only(
            //topRight: Radius.circular(25),
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Row(
            children: [
              //Text('Order Number: ' + orderItem.orderNumber ?? ''),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      // image: NetworkImage(orderItem.product.imageUrl),
                      image: CachedNetworkImageProvider(
                          orderItem.product!.imageUrl!)),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Container(
                          //color: Colors.red,
                          child: Text(
                            orderItem.product!.name!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      // Text(
                      //   orderItem.product.name,
                      //   style: TextStyle(color: Colors.white),
                      // ),
                      Text(
                        'P ' +
                            orderItem.product!.price +
                            ' x ' +
                            orderItem.quantity.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Total P ' +
                            (double.parse(orderItem.product!.price) *
                                    orderItem.quantity!)
                                .toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 30.0,
            child: new RaisedButton(
              //elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(5.0),
                  side: BorderSide(color: Colors.red)),
              color: Colors.white,
              // child: new Text(
              //     orderItem.status != 'cancelled'
              //         ? 'Cancel Order'
              //         : 'Cancelled',
              //     style: new TextStyle(fontSize: 12.0, color: Colors.red)),
              child: Consumer<ChangeNotifierChatOrder>(
                builder: (context, chatOrder, child) {
                  var label = 'Cancel Order';
                  if (chatOrder.getOrderStatus(orderItem.orderId) ==
                      STATUS_CANCELLED) {
                    label = 'Cancelled';
                  } else {
                    label = 'Cancel Order';
                  }

                  print('label' + label);

                  return Text(label,
                      style: new TextStyle(fontSize: 12.0, color: Colors.red));
                },
              ),
              onPressed: () {
                // If already cancelled then dont allow to press
                var chat = context.read<ChangeNotifierChatOrder>();
                if (chat.getOrderStatus(orderItem.orderId) ==
                    STATUS_CANCELLED) {
                  return;
                }
                print('order id: ' + orderItem.orderId.toString());
                showAlertDialog(context, orderItem, 'cancel');
              },
            ),
          ),
        ]),
      )
    ]);
  }

  Widget selectPaymentMethod(OrderItem? orderItem,
      [bool methodSelected = false]) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Padding(
      //     padding: EdgeInsets.only(left: 10),
      //     child: userImage(context, _seller, radius: 15)),
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.only(top: 10, left: 10),
          padding: EdgeInsets.all(5),
          width: 170.0,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              //topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15),
            ),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // userImage(_seller),
                Text('Select Payment Method'),
                SizedBox(
                  width: 150.0,
                  height: 30.0,
                  child: new RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(5.0)),
                      color: Colors.green[700],
                      child: new Text('Bank to Bank',
                          style: new TextStyle(
                              fontSize: 12.0, color: Colors.white)),
                      onPressed: null
                      // onPressed: () {
                      //   print('Open Bank to Bank');
                      // },
                      ),
                ),
                SizedBox(
                  width: 150.0,
                  height: 30.0,
                  child: new RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0)),
                    color: Colors.green[700],
                    child: new Text('Cash on Delivery',
                        style:
                            new TextStyle(fontSize: 12.0, color: Colors.white)),
                    onPressed: () {
                      // Do nothing if already selected payment method
                      // if (orderItem.paymentMethod != '') {
                      //   return;
                      // }

                      _navigateCheckout(context, orderItem, 'cod');

                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => Checkout(
                      //         orderItem: orderItem, paymentMethod: 'cod')));
                      // paymentMethod(orderItem, 'cod');
                      // sendTextMessage('Cash on Delivery');
                      //print('COD');
                    },
                  ),
                ),
                SizedBox(
                  width: 150.0,
                  height: 30.0,
                  child: new RaisedButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0)),
                    color: Colors.green[700],
                    child: new Text('Online Wallet',
                        style:
                            new TextStyle(fontSize: 12.0, color: Colors.white)),
                    //onPressed: null
                    onPressed: () {
                      // print('Open PayMaya Payment');
                      _navigateCheckout(context, orderItem, 'wallet');
                      // Navigator.of(context).push(MaterialPageRoute(
                      //     builder: (context) => Checkout(
                      //         orderItem: orderItem, paymentMethod: 'wallet')));
                    },
                  ),
                ),
              ]),
        ),
      ])
    ]);
  }

  _navigateCheckout(BuildContext context, OrderItem? orderItem,
      String selectedPaymentMethod) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Checkout(
              orderItem: orderItem, paymentMethod: selectedPaymentMethod)),
    );

    if (result != null) {
      if (result['result'] == 'success') {
        setState(() {
          _isLoading = true;
        });

        var address = result['address'];

        var message;

        // If success
        // if (selectedPaymentMethod == 'cod') {
        //   paymentMethod(orderItem, 'cod');
        //   sendTextMessage(textReply: 'Cash on Delivery', sendToServer: true);
        // } else {
        //   // Via Online Wallet
        //   paymentMethod(orderItem, 'wallet').then((value) {
        //     sendTextMessage(
        //         textReply: 'Paid via Online Wallet - ' +
        //             'Address: ' +
        //             address.name +
        //             ' ' +
        //             address.phone +
        //             ' ' +
        //             address.streetAddress,
        //         sendToServer: true);
        //   });
        // }

        paymentMethod(orderItem!, selectedPaymentMethod);
        sendTextMessage(
            textReply: (selectedPaymentMethod == 'cod'
                    ? 'Cash on Delivery - '
                    : 'Paid via Online Wallet -') +
                ' Name and Address: ' +
                address.name +
                ' ' +
                address.phone +
                ' ' +
                address.streetAddress +
                ' ' +
                address.barangay +
                ' ' +
                address.city +
                ' ' +
                address.province +
                ' ',
            sendToServer: true);

        setState(() {
          _isLoading = false;
        });
        print('payment success');
        //print(result.toString());
      }
    } else {
      print('cancelled');
      setState(() {
        _isLoading = false;
      });
    }

    // Navigator.of(context).pushNamedAndRemoveUntil(
    //     '/account/wallet', ModalRoute.withName('/'),
    //     arguments: {"_checkoutId": _checkoutId});
  }

  Widget showConfirmReject(OrderItem? orderItem, [bool isConfirmed = false]) {
    if (orderItem == null) {
      return Container();
    }

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        margin: EdgeInsets.only(top: 10, left: 10),
        padding: EdgeInsets.all(5),
        width: 230.0,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            //topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      // image: NetworkImage(orderItem.product.imageUrl),
                      image: CachedNetworkImageProvider(
                          orderItem.product!.imageUrl!)),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 130,
                        child: Container(
                          //color: Colors.red,
                          child: Text(
                            orderItem.product!.name!,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Text(
                        'P ' +
                            orderItem.product!.price +
                            ' x ' +
                            orderItem.quantity.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        'Total P ' +
                            (double.parse(orderItem.product!.price) *
                                    orderItem.quantity!)
                                .toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  )),
            ],
          ),
          isConfirmed
              ? SizedBox(
                  width: double.infinity,
                  height: 30.0,
                  child: new RaisedButton(
                    //elevation: 5.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.green)),
                    color: Colors.white,
                    child: new Text('Order Confirmed',
                        style: new TextStyle(
                            fontSize: 12.0, color: Colors.green[700])),
                    onPressed: () {},
                  ),
                )
              : Consumer<ChangeNotifierChatOrder>(
                  builder: (context, chatOrder, child) {
                    var label = 'Cancel Order';

                    String orderStatus =
                        chatOrder.getOrderStatus(orderItem.orderId);

                    Color textColor = Colors.green;

                    if (orderStatus == STATUS_CONFIRMED ||
                        orderStatus == STATUS_CANCELLED ||
                        orderStatus == STATUS_REJECTED) {
                      print('orderStatusExists ===' + orderStatus);
                      if (orderStatus == STATUS_CONFIRMED) {
                        label = 'Order Confirmed';
                      }
                      if (orderStatus == STATUS_CANCELLED) {
                        label = 'Order Cancelled';
                        textColor = Colors.red;
                      }
                      if (orderStatus == STATUS_REJECTED) {
                        label = 'Order Rejected';
                        textColor = Colors.red;
                      }
                      return SizedBox(
                        width: double.infinity,
                        height: 30.0,
                        child: new RaisedButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0),
                              side: BorderSide(color: textColor)),
                          color: Colors.white,
                          child: new Text(label,
                              style: new TextStyle(
                                  fontSize: 12.0, color: textColor)),
                          onPressed: () {},
                        ),
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 30.0,
                          child: new RaisedButton(
                            //elevation: 5.0,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.green)),
                            color: Colors.green[700],
                            child: new Text('Confirm',
                                style: new TextStyle(
                                    fontSize: 12.0, color: Colors.white)),
                            onPressed: () {
                              setState(() {
                                _areYouSureMessage = 'Are you sure you?';
                              });
                              showAlertDialog(context, orderItem, 'confirm');
                            },
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 30.0,
                          child: new RaisedButton(
                            //elevation: 5.0,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0),
                                side: BorderSide(color: Colors.red)),
                            color: Colors.white,
                            child: new Text('Reject',
                                style: new TextStyle(
                                    fontSize: 12.0, color: Colors.red)),
                            onPressed: () {
                              // Reject order
                              setState(() {
                                _areYouSureMessage =
                                    'Are you sure you want to reject?';
                              });
                              showAlertDialog(context, orderItem, 'reject');
                              // reject(orderItem);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                )
        ]),
      )
    ]);
  }

  showAlertDialog(BuildContext context, OrderItem orderItem,
      [String type = 'confirm']) {
    // can be confirm or cancel
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: SizedBox(
        width: 100,
        height: 30.0,
        child: new RaisedButton(
          //elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.green)),
          color: Colors.green[700],
          child: new Text('Yes',
              style: new TextStyle(fontSize: 12.0, color: Colors.white)),
          onPressed: () {
            // Confirm order here
            Navigator.pop(context);
            if (type == 'confirm') {
              print('yes to confirm: order id:' + orderItem.orderId.toString());
              confirm(orderItem);
            } else if (type == 'reject') {
              print('yes to reject: order id:' + orderItem.orderId.toString());
              reject(orderItem);
            } else {
              cancel(orderItem);
            }
          },
        ),
      ),
      onPressed: () {
        // Process the order
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: SizedBox(
        width: 100,
        height: 30.0,
        child: new RaisedButton(
          //elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.red)),
          color: Colors.white,
          child: new Text('No',
              style: new TextStyle(fontSize: 12.0, color: Colors.red)),
          onPressed: () {
            print('No to confirm. Do nothing');
            Navigator.pop(context);
          },
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Text(_areYouSureMessage),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<bool> paymentMethod(OrderItem orderItem, String paymentMethod) async {
    bool success =
        await paymentMethodOrder(orderItem.orderId.toString(), paymentMethod);

    if (success) {
      print('payment method!');
      // Provider.of<ChangeNotifierChatOrder>(context, listen: false)
      //     .setOrderStatus(orderItem.orderId, 'rejected');
      return true;
    } else {
      print('failed payment method');
      return false;
    }
  }

  Future<void> confirm(OrderItem orderItem) async {
    bool success = await confirmOrder(orderItem.orderId.toString());

    if (success) {
      print('confirmed!');
      Provider.of<ChangeNotifierChatOrder>(context, listen: false)
          .setOrderStatus(orderItem.orderId, STATUS_CONFIRMED);
      // Send message to other user once confirmed
      sendTextMessage(
          textReply:
              'Your order has been confirmed. The order status is set to processing.',
          orderId: orderItem.orderId.toString(),
          isConfirmed: true);

      // Show change status screen

    } else {
      print('failed confirm');
    }
  }

  Future<bool> cancel(OrderItem orderItem) async {
    bool success = await cancelOrder(orderItem.orderId.toString());

    if (success) {
      print('cancelled!');
      Provider.of<ChangeNotifierChatOrder>(context, listen: false)
          .setOrderStatus(orderItem.orderId, STATUS_CANCELLED);
      return true;
    } else {
      print('failed cancelled');
      return false;
    }
  }

  Future<bool> reject(OrderItem orderItem) async {
    bool success = await rejectOrder(orderItem.orderId.toString());

    if (success) {
      print('rejected!');
      Provider.of<ChangeNotifierChatOrder>(context, listen: false)
          .setOrderStatus(orderItem.orderId, STATUS_REJECTED);
      sendTextMessage(textReply: 'Your order has been rejected.');
      return true;
    } else {
      print('failed rejected');
      return false;
    }
  }

  Widget textMessageFromMe([String messages = 'Hello']) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .6),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Text(messages),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 16, top: 50),
        ),
      ],
    );
  }

  Widget textMessageFromOther([String message = '..']) {
    return Row(
      children: [
        // Padding(
        //     padding: EdgeInsets.only(left: 10),
        //     child: userImage(context, _seller, radius: 15)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // margin: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.only(left: 15.0, top: 5),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .8),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Color(0xffF0F0F0),
                // color: Colors.green[100],
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Text(message),
            ),
          ],
        ),
      ],
    );
  }

  Widget confirmChangeStatus([String? orderId = '']) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .6),
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 30.0,
                child: SizedBox(
                  width: 100,
                  height: 30.0,
                  child: new RaisedButton(
                    //elevation: 5.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        side: BorderSide(color: Colors.green)),
                    color: Colors.green[700],
                    child: new Text('Change order Status',
                        style:
                            new TextStyle(fontSize: 12.0, color: Colors.white)),
                    onPressed: () {
                      print('order status');
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => CupertinoActionSheet(
                          title: const Text('Change Status of Order'),
                          //message: const Text('Message'),
                          actions: [
                            CupertinoActionSheetAction(
                              child: const Text('Shipping'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: const Text('Delivered'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(right: 16, top: 50),
        ),
      ],
    );
  }

  Widget time() {
    return Padding(
        padding: EdgeInsets.only(top: 10),
        child: Center(
            child: Text(
          "12:00",
          style: TextStyle(color: Colors.grey),
        )));
  }

  void _sendMessage(String message) {
    _channel.sink.add(message);
  }

  Widget writeMessage() {
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          // margin: EdgeInsets.all(15.0),
          height: 76,
          child: Row(
            children: [
              // StreamBuilder(
              //   stream: _channel.stream,
              //   builder: (context, snapshot) {
              //     return Text(snapshot.hasData ? '${snapshot.data}' : '');
              //   },
              // ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(35.0),
                    // boxShadow: [
                    //   BoxShadow(
                    //       offset: Offset(0, 3),
                    //       blurRadius: 5,
                    //       color: Colors.grey)
                    // ],
                  ),
                  child: Row(
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.all(10.0),
                      //   decoration: BoxDecoration(
                      //       color: Colors.green[800], shape: BoxShape.circle),
                      //   child: IconButton(
                      //       icon: Icon(
                      //         Icons.photo_camera,
                      //         color: Colors.white,
                      //       ),
                      //       onPressed: () {
                      //         print('press camera');
                      //       }),
                      // ),
                      Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: new IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/plus.svg',
                                height: 42.6,
                                width: 42.6,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                print('tap +');
                              })),
                      Expanded(
                        child: TextFormField(
                          controller: _messageController,
                          autofocus: true,
                          textInputAction: TextInputAction.send,
                          onFieldSubmitted: (term) {
                            // process
                            sendTextMessage();
                            _sendMessage(_messageController.text);
                            print('send');
                          },
                          decoration: InputDecoration(
                              hintText: "Message...",
                              // hintText: "Message... chat_" +
                              //     widget.user!.id! +
                              //     ' receiver',
                              border: InputBorder.none),
                        ),
                      ),
                      // new IconButton(
                      //     icon: SvgPicture.asset(
                      //       'assets/images/plus.svg',
                      //       height: 42.6,
                      //       width: 42.6,
                      //       color: Colors.green,
                      //     ),
                      //     onPressed: () {
                      //       print('tap +');
                      //     }),
                      IconButton(
                        icon: Icon(
                          _hasMessage ? Icons.send : null,
                          color: Colors.green[700],
                        ),
                        onPressed: () {
                          if (_hasMessage) {
                            print('send message');
                            sendTextMessage();
                          } else {
                            print('press photo');
                          }
                        },
                      ),
                      // IconButton(
                      //   icon: Icon(
                      //     _hasMessage
                      //         ? Icons.send
                      //         : Icons.add_photo_alternate_outlined,
                      //     color: Colors.green[700],
                      //   ),
                      //   onPressed: () {
                      //     if (_hasMessage) {
                      //       print('send message');
                      //       sendTextMessage();
                      //     } else {
                      //       print('press photo');
                      //     }
                      //   },
                      // ),
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.keyboard_voice,
                      //     color: Colors.grey[700],
                      //   ),
                      //   onPressed: () {
                      //     print('press mic');
                      //   },
                      // )
                    ],
                  ),
                ),
              ),
              //SizedBox(width: 15),
              // Container(
              //   padding: const EdgeInsets.all(15.0),
              //   decoration:
              //       BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              //   child: InkWell(
              //     child: Icon(
              //       Icons.keyboard_voice,
              //       color: Colors.white,
              //     ),
              //     onLongPress: () {
              //       setState(() {
              //         //_showBottom = true;
              //       });
              //     },
              //   ),
              // )
            ],
          ),
        ));
  }

  void sendTextMessage(
      {String? textReply,
      bool? sendToServer,
      bool? isConfirmed,
      String? orderId}) async {
    // Todo Call API to store messages
    final SharedPreferences prefs = await _prefs;
    String? userId = await prefs.getString('userId');
    //print(textReply + ':message');

    var message = _messageController.text;
    if (textReply != null) {
      message = textReply;
    }
    setState(() {
      _isNew = true;
      // Add at the beginning
      _chatItems.insert(0, textMessageFromMe(message));
      _messageController.text = '';
      FocusScope.of(context).requestFocus(_messageField);

      if (isConfirmed == true) {
        // Show confirm box to change status
        _chatItems.insert(0, confirmChangeStatus(orderId));
      }
    });

    print(message);
    // Send only to server if actually text message
    if (textReply == null || sendToServer == true) {
      if (!mounted) {
        return;
      }

      await sendChatMessage(
              ChatMessage('', TYPE_TEXT, widget.user!.id, userId, message))
          .then((sendMessage) {
        // For sending
        // If the inbox is null then we could get inbox after sending message
        if (widget.inbox != null) {
          Inbox inbox = widget.inbox!;
          inbox.messages = message;

          // Change inbox position to the top
          Provider.of<ChangeNotifierInbox>(context, listen: false)
              .sortInbox(inbox, widget.inboxIndex!);
        } else {
          // Put position to the top
          print('Put position to the top');
          Inbox inbox = Inbox.fromMap(sendMessage['inbox']);
          inbox.messages = message;
          Provider.of<ChangeNotifierInbox>(context, listen: false)
              .addInbox(inbox);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setChatItems();

    return Scaffold(
      appBar: appBarTopWithBack(context, isMain: false, title: _seller!.name!),
      // appBar: AppBar(
      //   backgroundColor: body_color,
      //   title: userAccount(context, _seller),
      //   elevation: 0,
      //   leading: popArrow(context),
      //   actions: [
      //     Padding(
      //         padding: EdgeInsets.only(right: 16),
      //         child: Icon(
      //           Icons.more_horiz_outlined,
      //           color: Colors.grey,
      //         ))
      //   ],
      //   bottomOpacity: 0.0,
      // ),
      //backgroundColor: body_color,
      // body: new Container(
      //   //color: Colors.red,
      //   child: ListView(reverse: true, children: [
      //     // children in reverse order. Most recent items will go to bottom
      //     // textMessageFromOther(),
      //     // textMessageFromMe(),
      //     selectPaymentMethod(),
      //     time(),
      //     // Expanded(child: Divider(color: Colors.transparent, thickness: 10)),
      //     showOrder(_orderItem),
      //     time(),
      //   ]),
      // ),
      body: _isLoading
          ? spin()
          : new Container(
              //color: Colors.red,
              child: ListView(
                reverse: true,
                children: _chatItems.map((Widget widget) {
                  return widget;
                }).toList(),
              ),
            ),
      bottomNavigationBar: SafeArea(child: writeMessage()),
    );
  }
}
