import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';
import 'package:magri/Constants.dart';
import 'package:magri/models/changenotifiers/changenotifierinbox.dart';
import 'package:magri/widgets/pages/splash_screens/splash_page_one.dart';
import 'dart:io' show Platform;
import './models/changenotifiers/changenotifieruser.dart';
import 'package:provider/provider.dart';
// import 'package:pusher/pusher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'models/changenotifiers/change_notifier_chat_order.dart';
import 'models/changenotifiers/change_notifier_payment.dart';
import 'models/changenotifiers/changenotifier_connection.dart';
import 'models/changenotifiers/changenotifieraddress.dart';
import 'package:get/get.dart';
import 'services/authentication.dart';
import 'widgets/pages/root_page.dart';

import 'util/router.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  debugPaintSizeEnabled =
      false; // This will show some lines on widget when set to true
  // Run only on android because we automatically have it on iOS
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // This is when received push while app is on background or not active
  // on screen
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Test pusher
  // Pusher pusher = new Pusher('1009472', '04dfcd4b13e17fae943f', 'd02761354ccf2023597b', PusherOptions(cluster: 'ap1'));
  // Map data = {'message': 'Hello world'};
  // Response response = await pusher.trigger(['test_channel_hehe'], 'my_event', data);
  // print('pusher sent' + response.toString());

  // FirebaseDatabase.instance.setPersistenceEnabled(true);

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  //Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  //FlutterError.onError = Crashlytics.instance.recordFlutterError;

  //runApp(MyApp());
  // runZoned(() {
  //   runApp(MyApp());
  // }, onError: Crashlytics.instance.recordError);

  // https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple
  runZonedGuarded(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ChangeNotifierUser()),
          ChangeNotifierProvider(create: (context) => ChangeNotifierPayment()),
          ChangeNotifierProvider(create: (context) => ChangeNotifierAddress()),
          ChangeNotifierProvider(create: (context) => ChangeNotifierInbox()),
          ChangeNotifierProvider(
              create: (context) => ChangeNotifierConnection()),
          ChangeNotifierProvider(
              create: (context) => ChangeNotifierChatOrder()),
        ],
        child: MyApp(),
      ),
      // ChangeNotifierProvider(
      //   create: (context) => CartModel(),
      //   child: MyApp(),
      // ), //  This is for single
    );
  }, FirebaseCrashlytics.instance.recordError);
}
// old main
//void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // MaterialApp //  Old
    return GetMaterialApp(
      title: 'MAgri App',
      debugShowCheckedModeBanner:
          DEBUG_SHOW_MODE_BANNER, //  Remove debug ribbon on top right corner
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        //primarySwatch: Colors.blue,
        //accentColor: Colors.green,
        // Define the default font family.
        fontFamily: 'ProximaNova',

        //buttonTheme: ButtonTheme(),

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          // headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          // headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          // bodyText2: TextStyle(fontSize: 14.0),
          headline6: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold), // This for bold labels
        ),
      ),
      //darkTheme: ThemeData.dark(),// https://medium.com/@pmutisya/dark-mode-in-flutter-3742062f9f59
      // home: MyHomePage(),
      home: new SplashPageOne(),
      // home: new RootPage(auth: new Auth()),
      routes: appRoutes as Map<String, Widget Function(BuildContext)>,
      // },
    );
  }
}

// This is the orig home page. We can remove below code
// class MyHomePage extends StatelessWidget {

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: NavDrawer(),
//       appBar: AppBar(
//         title: Text('POS App'),
//       ),
//       body: Center(
//         child: Text('Center'),
//       ),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // _posId = _prefs.then((SharedPreferences prefs) {
    //   return (prefs.getString('_posId') ?? 'o');
    // });

    // Check here if already have data then if not redirect register/login

    // If already have data then just show PIN entry

    //print(_posId.toString());
    //Navigator.pushNamed(context, '/login/pin');
    //_save();
    //_getPref('posId');
  }

  // _getPref(key) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // final key = 'posId';
  //   final value = prefs.getString(key) ?? 'okay';

  //   return value;
  //   //print(key + ': $value');
  // }

  @override
  Widget build(BuildContext context) {
    // If blank then we can ask the user to enter pin

    // https://github.com/flutter/samples/blob/master/provider_shopper/lib/main.dart

    // https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad
    // https://pub.dev/packages/flutter_bloc

    return Scaffold(
      appBar: AppBar(
        title: Text('MAgri App'),
      ),
      body: Center(
        child: Text('Center'),
      ),
    );
  }
}
