import 'package:flutter/material.dart';
import 'driver_form2.dart';
import 'models/driver_model.dart';

class AddDriverPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          SizedBox(width: 8),
                          Text('Dashboard', style: TextStyle(fontSize: 16, color: Colors.black87)),
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
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, size: 24, color: Colors.blue),
                              SizedBox(width: 10),
                              Text('Add Driver', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue[900])),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel('Username'),
                            buildTextField(
                              hint: 'Username',
                              icon: Icons.person_outline,
                              controller: usernameController,
                              validator: (value) => value!.isEmpty ? 'Username is required' : null,
                            ),
                            buildLabel('Password'),
                            buildTextField(
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Password is required';
                                if (value.length < 6) return 'Minimum 6 characters';
                                return null;
                              },
                            ),
                            buildLabel('First Name'),
                            buildTextField(
                              hint: 'First Name',
                              icon: Icons.badge_outlined,
                              controller: firstNameController,
                              validator: (value) => value!.isEmpty ? 'First name is required' : null,
                            ),
                            buildLabel('Last Name'),
                            buildTextField(
                              hint: 'Last Name',
                              icon: Icons.badge,
                              controller: lastNameController,
                              validator: (value) => value!.isEmpty ? 'Last name is required' : null,
                            ),
                            buildLabel('Email'),
                            buildTextField(
                              hint: 'Email',
                              icon: Icons.email_outlined,
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Email is required';
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            buildLabel('Phone'),
                            buildPhoneField(),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              _formKey.currentState!.reset();
                              usernameController.clear();
                              passwordController.clear();
                              firstNameController.clear();
                              lastNameController.clear();
                              emailController.clear();
                              phoneController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Form cleared.'), backgroundColor: Colors.redAccent),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DriverForm2(
                                      customer: DriverModel(
                                        username: usernameController.text,
                                        password: passwordController.text,
                                        firstName: firstNameController.text,
                                        lastName: lastNameController.text,
                                        email: emailController.text,
                                        phone: phoneController.text,
                                        vehicleReg: '',
                                        vehicleCode: '',
                                        gender: '',
                                        addresses: [],
                                        avatarUrl: '',
                                        notes: '',
                                        status: 'active',
                                        newsletter: 'yes',
                                        notify: false,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Image.network('https://flagcdn.com/w40/ma.png', width: 24),
                SizedBox(width: 8),
                Text('+212', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Phone number is required';
                if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) return 'Enter 9-digit phone';
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone, color: Colors.black54),
                hintText: 'Phone',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
