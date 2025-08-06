import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'DriverWebForm.dart';
import 'driver_form1.dart';


class RegisterDriverScreen extends StatelessWidget {
  const RegisterDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const DriverWebForm(); // Web version: one full-page form
    } else {
      return AddDriverPage(); // Mobile version: step-by-step form
    }
  }
}
