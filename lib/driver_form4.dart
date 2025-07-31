import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/driver_model.dart';

class driver_form4  extends StatefulWidget {
  final DriverModel customer;

  const driver_form4({Key? key, required this.customer}) : super(key: key);

  @override
  State<driver_form4> createState() => _AddCustomerFinalFormState();
}

class _AddCustomerFinalFormState extends State<driver_form4> {
  final _formKey = GlobalKey<FormState>();

  String userStatus = 'active';
  String newsletterSub = 'yes';
  bool notifyUser = false;

  final TextEditingController avatarUrlController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing customer data if any
    userStatus = widget.customer.status;
    newsletterSub = widget.customer.newsletter;
    notifyUser = widget.customer.notify;
    avatarUrlController.text = widget.customer.avatarUrl;
    notesController.text = widget.customer.notes;
  }

  @override
  void dispose() {
    avatarUrlController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Create updated customer model with latest form values
    final updatedCustomer = widget.customer.copyWith(
      status: userStatus,
      newsletter: newsletterSub,
      avatarUrl: avatarUrlController.text,
      notes: notesController.text,
      notify: notifyUser,
    );

    try {
      // 1. Create Firebase Authentication user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: updatedCustomer.email,
        password: updatedCustomer.password,
      );

      final uid = userCredential.user!.uid;

      // 2. Save customer data in Firestore under 'clients' collection with UID
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(uid)
          .set(updatedCustomer.toJson());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver successfully added!')),
      );

      // Navigate back to start or wherever
      Navigator.popUntil(context, (route) => route.isFirst);

    } on FirebaseAuthException catch (e) {
      // Show auth error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication Error: ${e.message}')),
      );
    } catch (e) {
      // Show unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5),
      child: Text(
        text,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10),
                  Text('Dashboard', style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 10),

              // Banner
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/steering-wheel.png',
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add Driver',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Status
                    buildLabel("User Status"),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'inactive',
                          groupValue: userStatus,
                          onChanged: (value) => setState(() => userStatus = value!),
                          activeColor: Colors.deepPurple,
                        ),
                        Text('Inactive'),
                        Radio<String>(
                          value: 'active',
                          groupValue: userStatus,
                          onChanged: (value) => setState(() => userStatus = value!),
                          activeColor: Colors.deepPurple,
                        ),
                        Text('Active'),
                      ],
                    ),

                    // Newsletter
                    buildLabel("Newsletter Subscriber"),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'no',
                          groupValue: newsletterSub,
                          onChanged: (value) => setState(() => newsletterSub = value!),
                          activeColor: Colors.deepPurple,
                        ),
                        Text('No'),
                        Radio<String>(
                          value: 'yes',
                          groupValue: newsletterSub,
                          onChanged: (value) => setState(() => newsletterSub = value!),
                          activeColor: Colors.deepPurple,
                        ),
                        Text('Yes'),
                      ],
                    ),

                    // Avatar URL
                    buildLabel("User Avatar"),
                    TextFormField(
                      controller: avatarUrlController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please insert a URL';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Insert the URL for your avatar',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Notify checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: notifyUser,
                          onChanged: (value) => setState(() => notifyUser = value!),
                          activeColor: Colors.deepPurple,
                        ),
                        Text("Notify User"),
                      ],
                    ),

                    // Notes
                    buildLabel("User Notes – For internal use only."),
                    TextFormField(
                      controller: notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'User Notes – For internal use only',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      avatarUrlController.clear();
                      notesController.clear();
                      setState(() {
                        notifyUser = false;
                        userStatus = 'active';
                        newsletterSub = 'yes';
                      });
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      "Add new Driver",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
