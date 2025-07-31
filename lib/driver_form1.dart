import 'package:flutter/material.dart';
import 'driver_form2.dart';
import 'models/driver_model.dart';

class AddDriverPage  extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button & Title
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {},
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Dashboard',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Add Customer Banner
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

                // Form fields
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel('Username'),
                      buildTextField(
                        'Username',
                        controller: usernameController,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Username is required' : null,
                      ),

                      buildLabel('Password'),
                      buildTextField(
                        'Password',
                        isPassword: true,
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 6) {
                            return 'Minimum 6 characters';
                          }
                          return null;
                        },
                      ),

                      buildLabel('First Name'),
                      buildTextField(
                        'First Name',
                        controller: firstNameController,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'First name is required' : null,
                      ),

                      buildLabel('Last Name'),
                      buildTextField(
                        'Last Name',
                        controller: lastNameController,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Last name is required' : null,
                      ),

                      buildLabel('Email'),
                      buildTextField(
                        'Email',
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      buildLabel('Phone'),
                      buildPhoneField(),
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
                        usernameController.clear();
                        passwordController.clear();
                        firstNameController.clear();
                        lastNameController.clear();
                        emailController.clear();
                        phoneController.clear();
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => driver_form2(
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
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
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

  Widget buildTextField(String hint,
      {bool isPassword = false,
        TextEditingController? controller,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
    );
  }

  Widget buildPhoneField() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Image.network(
                'https://flagcdn.com/w40/ma.png',
                width: 24,
              ),
              SizedBox(width: 6),
              Text('+212'),
            ],
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              } else if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) {
                return 'Enter 9-digit phone';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Phone',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
