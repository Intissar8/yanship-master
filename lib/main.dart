import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yanship/register_client_screen.dart';
import 'package:yanship/register_driver_screen.dart';
import 'package:yanship/register_screen.dart';
import 'acceuil.dart';
import 'add_shipment_screen.dart';
import 'customer_form1.dart';
import 'customer_form3.dart';
import 'dashboardC.dart';
import 'driver_form1.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb)
    {
     await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyDzY5E2MHClH9ruIyGxW6i_7hxVxi0y9Fc",
          authDomain: "yanship-c3893.firebaseapp.com",
          projectId: "yanship-c3893",
          storageBucket: "yanship-c3893.firebasestorage.app",
          messagingSenderId: "969048987321",
          appId: "1:969048987321:web:211b0221f04f096a9a6d68"));

    }else{
    await Firebase.initializeApp();
  }




  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}


