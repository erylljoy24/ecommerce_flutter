import 'package:flutter/material.dart';
import '../widgets/pages/account_settings.dart';
import '../widgets/pages/help_center.dart';
import '../widgets/pages/myrating.dart';
import '../widgets/pages/my_wallet.dart';
import '../widgets/pages/account/verify_account.dart';

// Settings
import '../widgets/pages/products/add_product.dart';
import '../widgets/pages/events/events.dart';

Object appRoutes = {
  //'/view/profile': (BuildContext context) => ViewProfile(),
  '/account/verify': (BuildContext context) => VerifyAccount(),
  '/account/wallet': (BuildContext context) => MyWallet(),
  '/account/rating': (BuildContext context) => MyRating(),
  '/account/settings': (BuildContext context) => AccountSettings(),
  '/account/help': (BuildContext context) => HelpCenter(),
  '/products/add': (BuildContext context) => AddProduct(),
  // '/products/view': (BuildContext context) => ViewProduct(),
  '/events/index': (BuildContext context) => Events(),
  // '/events/view': (BuildContext context) => EventView(),
};
