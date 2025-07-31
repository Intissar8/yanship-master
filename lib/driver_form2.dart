import 'package:flutter/material.dart';

import 'driver_form3.dart';
import 'models/driver_model.dart';

class driver_form2   extends StatefulWidget {
  final DriverModel customer;

  const driver_form2({Key? key, required this.customer}) : super(key: key);

  @override
  State<driver_form2> createState() => _CustomerForm2State();
}

class _CustomerForm2State extends State<driver_form2> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController vehicleRegController = TextEditingController();
  final TextEditingController vehicleCodeController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    vehicleRegController.dispose();
    vehicleCodeController.dispose();
    super.dispose();
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
              // Back button & title
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

              // Header
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

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLabel("Vehicule registration number"),
                    buildTextField(
                      controller: vehicleRegController,
                      hint: "Vehicule registration number",
                      validator: (value) =>
                      value == null || value.isEmpty ? "This field is required" : null,
                    ),
                    buildLabel("Vehicule code"),
                    buildTextField(
                      controller: vehicleCodeController,
                      hint: "Vehicule code",
                      validator: (value) =>
                      value == null || value.isEmpty ? "This field is required" : null,
                    ),
                    buildLabel("Gender"),
                    buildGenderDropdown(),
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
                      vehicleRegController.clear();
                      vehicleCodeController.clear();
                      setState(() {
                        selectedGender = null;
                      });
                    },
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && selectedGender != null) {
                        // Update customer model
                        DriverModel updatedCustomer = widget.customer.copyWith(
                          vehicleReg: vehicleRegController.text,
                          vehicleCode: vehicleCodeController.text,
                          gender: selectedGender!,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DriverForm3(customer: updatedCustomer),
                          ),
                        );
                      } else if (selectedGender == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please select a gender")),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
    );
  }

  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      items: ['femme', 'homme'].map((gender) {
        return DropdownMenuItem(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      decoration: InputDecoration(
        hintText: "Dropdown option",
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
      onChanged: (value) {
        setState(() {
          selectedGender = value;
        });
      },
      validator: (_) {
        return selectedGender == null ? 'Please select a gender' : null;
      },
    );
  }
}
