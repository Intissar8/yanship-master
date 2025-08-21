import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/customer_model.dart';

// 🔴 new imports
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'models/driver_model.dart';

class DriverWebForm  extends StatefulWidget {
  const DriverWebForm ({super.key});

  @override
  State<DriverWebForm > createState() => _CustomerWebFormState();
}

class _CustomerWebFormState extends State<DriverWebForm > {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vehicleRegController = TextEditingController();
  final TextEditingController vehicleCodeController = TextEditingController();
  String? selectedGender;

  List<Map<String, TextEditingController>> addressList = [];

  // 🔴 instead of avatarUrlController
  String? avatarBase64;

  final TextEditingController notesController = TextEditingController();
  String userStatus = 'active';
  String newsletterSub = 'yes';
  bool notifyUser = false;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker(); // 🔴 picker instance

  @override
  void initState() {
    super.initState();
    addNewAddress();
  }

  void addNewAddress() {
    setState(() {
      addressList.add({
        'address': TextEditingController(),
        'country': TextEditingController(),
        'city': TextEditingController(),
        'zip': TextEditingController(),
      });
    });
  }

  // 🔴 pick & convert to base64
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await pickedFile.readAsBytes();
      setState(() => avatarBase64 = base64Encode(bytes));
    } else {
      File file = File(pickedFile.path);
      Uint8List bytes = await file.readAsBytes();
      setState(() => avatarBase64 = base64Encode(bytes));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || selectedGender == null) {
      if (selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a gender")),
        );
      }
      return;
    }

    setState(() => isLoading = true);

    List<Map<String, dynamic>> addresses = addressList.map((addr) => {
      'address': addr['address']!.text,
      'country': addr['country']!.text,
      'city': addr['city']!.text,
      'zip': addr['zip']!.text,
    }).toList();

    DriverModel customer = DriverModel(
      username: usernameController.text,
      password: passwordController.text,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneController.text,
      vehicleReg: vehicleRegController.text,
      vehicleCode: vehicleCodeController.text,
      gender: selectedGender!,
      addresses: addresses,
      avatarUrl: avatarBase64 ?? "", // ✅ empty string if no image
      notes: notesController.text,
      status: userStatus,
      newsletter: newsletterSub,
      notify: notifyUser,
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: customer.email, password: customer.password);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(uid)
          .set(customer.toJson());

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Driver registered successfully!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message ?? e.code}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 24, color: Colors.blue),
                        const SizedBox(width: 10),
                        Text(
                          'Add Driver',
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
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildCard("Account Info", [
                              _buildTextField(usernameController, "Username", Icons.person_outline),
                              _buildTextField(passwordController, "Password", Icons.lock_outline, isPassword: true),
                              _buildTextField(firstNameController, "First Name", Icons.badge_outlined),
                              _buildTextField(lastNameController, "Last Name", Icons.badge),
                              _buildTextField(emailController, "Email", Icons.email_outlined, isEmail: true),
                              _buildTextField(phoneController, "Phone", Icons.phone, isPhone: true),
                            ]),
                            const SizedBox(height: 24),
                            _buildCard("Addresses", [
                              ...addressList.map((addr) => Column(
                                children: [
                                  _buildTextField(addr['address']!, "Address", Icons.home),
                                  _buildTextField(addr['country']!, "Country", Icons.flag),
                                  _buildTextField(addr['city']!, "City", Icons.location_city),
                                  _buildTextField(addr['zip']!, "Zip", Icons.numbers, isNumber: true),
                                  const Divider(),
                                ],
                              )),
                              TextButton.icon(
                                onPressed: addNewAddress,
                                icon: const Icon(Icons.add, color: Colors.blue),
                                label: const Text("Add Another Address", style: TextStyle(color: Colors.blue)),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildCard("Vehicle Info", [
                              _buildTextField(vehicleRegController, "Vehicle Registration", Icons.directions_car),
                              _buildTextField(vehicleCodeController, "Vehicle Code", Icons.code),
                              DropdownButtonFormField<String>(
                                value: selectedGender,
                                items: ["homme", "femme"]
                                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                    .toList(),
                                onChanged: (v) => setState(() => selectedGender = v),
                                validator: (_) => selectedGender == null ? 'Select gender' : null,
                                decoration: const InputDecoration(labelText: "Gender"),
                              ),
                            ]),
                            const SizedBox(height: 24),
                            _buildCard("Final Info", [
                              // 🔴 avatar picker & preview
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: CircleAvatar(
                                      radius: 40,
                                      backgroundImage: avatarBase64 != null
                                          ? MemoryImage(base64Decode(avatarBase64!))
                                          : null,
                                      child: avatarBase64 == null
                                          ? const Icon(Icons.camera_alt, size: 32)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Tap to upload profile picture"),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(notesController, "Notes", Icons.note, maxLines: 3, isOptional: true),
                              _buildRadioGroup("User Status", userStatus, ['active', 'inactive'], (v) => setState(() => userStatus = v)),
                              _buildRadioGroup("Newsletter", newsletterSub, ['yes', 'no'], (v) => setState(() => newsletterSub = v)),
                              CheckboxListTile(
                                title: const Text("Notify user"),
                                value: notifyUser,
                                onChanged: (v) => setState(() => notifyUser = v!),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  ),
                                  onPressed: isLoading ? null : _submitForm,
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 12),
          ...children
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool isEmail = false, bool isPhone = false, bool isNumber = false, int maxLines = 1, bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        maxLines: maxLines,
        keyboardType: isNumber
            ? TextInputType.number
            : isPhone
            ? TextInputType.phone
            : isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        validator: (value) {
          if (isOptional) return null;
          if (value == null || value.isEmpty) return 'Required';
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Invalid email';

          if (isPhone && !RegExp(r'^\d{9}$').hasMatch(value)) return '9-digit phone required';

          if (isPassword && value.length < 6) return 'Minimum 6 characters';

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRadioGroup(String title, String groupValue, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: options
              .map((opt) => Row(
            children: [
              Radio<String>(
                value: opt,
                groupValue: groupValue,
                onChanged: (val) => onChanged(val!),
              ),
              Text(opt[0].toUpperCase() + opt.substring(1)),
            ],
          ))
              .toList(),
        ),
      ],
    );
  }
}
