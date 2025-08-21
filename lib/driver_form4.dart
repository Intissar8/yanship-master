import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/customer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/driver_model.dart';

class driver_form4 extends StatefulWidget {
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

  String? avatarBase64;
  final TextEditingController notesController = TextEditingController();

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userStatus = widget.customer.status;
    newsletterSub = widget.customer.newsletter;
    notifyUser = widget.customer.notify;
    avatarBase64 = widget.customer.avatarUrl; // can be null
    notesController.text = widget.customer.notes;
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 80,
    );

    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      setState(() {
        avatarBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Driver successfully added!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (avatarBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload an avatar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updatedCustomer = widget.customer.copyWith(
      status: userStatus,
      newsletter: newsletterSub,
      avatarUrl: avatarBase64!,
      notes: notesController.text,
      notify: notifyUser,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: updatedCustomer.email,
        password: updatedCustomer.password,
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(uid)
          .set(updatedCustomer.toJson());

      await _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 700 ? 700 : constraints.maxWidth;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Container(
                  width: maxWidth,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(width: 8),
                            Text('Dashboard', style: TextStyle(fontSize: 16, color: Colors.black)),
                          ],
                        ),
                        SizedBox(height: 16),

                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(
                                  'Finalize Driver',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.blue[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

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

                        // Avatar Picker
                        buildLabel("User Avatar"),
                        Center(
                          child: Column(
                            children: [
                              avatarBase64 != null
                                  ? CircleAvatar(
                                radius: 50,
                                backgroundImage: MemoryImage(base64Decode(avatarBase64!)),
                              )
                                  : CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade300,
                                child: Icon(Icons.person, size: 50, color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.upload),
                                label: Text("Upload Avatar"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),

                        // Notify
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                _formKey.currentState!.reset();
                                notesController.clear();
                                setState(() {
                                  notifyUser = false;
                                  userStatus = 'active';
                                  newsletterSub = 'yes';
                                  avatarBase64 = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Form reset."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                                  : Text(
                                "Add New Driver",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
