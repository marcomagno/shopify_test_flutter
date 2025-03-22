import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_shopify_test/src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // ServiceLocator.instance.kickoff();
  //HttpOverrides.global = MyHttpOverrides();
  runApp(const App());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
