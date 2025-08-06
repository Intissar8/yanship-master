import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'CustomerWebForm.dart';
import 'customer_form1.dart';


class RegisterClientScreen extends StatelessWidget {
  const RegisterClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const CustomerWebForm(); // Web version: one full-page form
    } else {
      return AddCustomerPage(); // Mobile version: step-by-step form
    }
  }
}
