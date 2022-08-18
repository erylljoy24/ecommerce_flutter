import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:magri/controllers/userController.dart';
import 'package:magri/widgets/pages/new_home_page/new_home_page.dart';
import 'package:magri/widgets/pages/start.dart';
import 'package:magri/widgets/pages/login_signup_page.dart';
import 'package:magri/services/authentication.dart';
import 'package:magri/widgets/pages/home_page.dart';
import 'package:magri/models/user.dart';
import 'package:provider/provider.dart';
import 'package:magri/models/changenotifiers/changenotifieruser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/NotificationController.dart';
import 'otp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
  FIRST_TIME,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth? auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final UserController userController = Get.put(UserController());
  final NotificationController notificationController =
      Get.put(NotificationController());
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  bool? _appUsed = false;
  String? _userId = '';

  bool signout = false;

  User? _user;

  @override
  void initState() {
    super.initState();
    print('root_page.dart');
    // We need to change the checking of login user.
    // Need to check if we have user_id and auth token store in shared
    // widget.auth.getCurrentUser().then((user) {
    //   setState(() {
    //     if (user != null) {
    //       _userId = user?.uid;
    //     }
    //     authStatus =
    //         user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
    //   });
    // });

    getSecureStorage();

    widget.auth!.getLoggedInUser().then((user) {
      userController.setUser(user);
      print(user.email);
      print(user.id);
      print("_appUsed:" + _appUsed.toString());
      setState(() {
        _userId = user.id;
        _user = user;
        if (_userId != null) {
          requestNotificationPermission();
        }
// We can call on this instead on build method
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Provider.of<ChangeNotifierUser>(context, listen: false)
              .setUser(_user);
        });

        authStatus =
            user.id == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });

      if (_appUsed == null) {
        // authStatus = AuthStatus.FIRST_TIME;
      }
    });

    print('authStatus: ' + authStatus.toString());
  }

  void requestNotificationPermission() async {
    final SharedPreferences prefs = await _prefs;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus.toString() ==
        'AuthorizationStatus.authorized') {
      messaging.getToken().then((token) async {
        print('push --- token: ' + token.toString());
        // Store it in database. We need to check first if the token is stored
        // already on database

        await FirebaseMessaging.instance.subscribeToTopic('magriappmessages');

        // await widget.auth!.writePref(token.toString(), 'stored');

        prefs.setBool('notificationOn', true);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
          print('Message also contained a notification: ' +
              message.notification!.title!);

          // setState(() {
          //   _openNotif = false;
          // });

          // Increment notifications
          notificationController.increment();
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        print('Message clicked!');
        print("message: ${message.messageId}");
        print("title: ${message.notification!.title!}");
        print("body: ${message.notification!.body!}");

        setState(() {
          // _openNotif = true;
        });
      });
    } else {
      // Disable the tokens
    }
  }

  void getSecureStorage() async {
    final SharedPreferences prefs = await _prefs;

    bool? appUsed = await prefs.getBool('appUsed');
    setState(() {
      _appUsed = appUsed;
    });
  }

  // This method is called from login so that we can set the data
  void loginCallback() {
    widget.auth!.getLoggedInUser().then((user) {
      userController.setUser(user);
      setState(() {
        authStatus = AuthStatus.LOGGED_IN;
        _userId = user.id;
        _user = user;
        print('loginCallback: loginCallback');
        print(user.email);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Provider.of<ChangeNotifierUser>(context, listen: false)
              .setUser(_user);
        });
      });
    });
  }

  // When user is in Start page it will directly called on Start page
  // by passing this as parameter in a class return new Start(startCallback: startCallback);
  // in start page we add as :
  // Start({this.startCallback});
  // final VoidCallback startCallback;
  // then it can be called in Start page as widget.startCallback();
  void startCallback() async {
    print("startCallback:");
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool('appUsed', true);
    setState(() {
      _appUsed = true;
      authStatus = AuthStatus
          .NOT_LOGGED_IN; // Set to not login so that we show login page
    });
  }

  // void loginCallback() {
  //   widget.auth.getCurrentUser().then((user) {
  //     setState(() {
  //       _userId = user.uid.toString();
  //     });
  //   });
  //   setState(() {
  //     authStatus = AuthStatus.LOGGED_IN;
  //   });
  // }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = '';
    });
    logoutGoogle();
  }

  void logoutGoogle() async {
    await _googleSignIn.signOut();
    print('logoutGoogle');
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   // statusBarColor: Colors.white,
    //   statusBarBrightness: Brightness.dark,
    // ));

    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        print('waiting screen...');
        return buildWaitingScreen();
      case AuthStatus.NOT_LOGGED_IN:
        print('login screen.....');
        // return new Otp();
        return new LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
      // case AuthStatus.FIRST_TIME:
      //   print('start');
      //   return new Start(startCallback: startCallback);
      case AuthStatus.LOGGED_IN:
        print('LOGGED_IN screen...');
        print(_userId);

        if (_userId != null) {
          if (_userId!.length > 0) {
            return new NewHomePage(
              userId: _userId,
              auth: widget.auth,
              logoutCallback: logoutCallback,
            );
          }
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }

    return buildWaitingScreen();
  }
}
