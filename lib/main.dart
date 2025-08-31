import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yanship/register_client_screen.dart';
import 'package:yanship/register_driver_screen.dart';
import 'package:yanship/register_screen.dart';
import 'Shipment_admin_page.dart';
import 'acceuil.dart';
import 'add_shipment_screen.dart';
import 'adminProfileScreen.dart';
import 'create_shipp_admin.dart';
import 'customer_form1.dart';
import 'customer_form3.dart';
import 'dashboardC.dart';
import 'driver_form1.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDzY5E2MHClH9ruIyGxW6i_7hxVxi0y9Fc",
        authDomain: "yanship-c3893.firebaseapp.com",
        projectId: "yanship-c3893",
        storageBucket: "yanship-c3893.firebasestorage.app",
        messagingSenderId: "969048987321",
        appId: "1:969048987321:web:211b0221f04f096a9a6d68",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // default is English

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ShipmentFormStyledPage(),
    );
  }
}
