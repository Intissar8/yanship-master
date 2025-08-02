import 'package:flutter/material.dart';
import 'customer_form3.dart';
import 'models/customer_model.dart';

class CustomerForm2 extends StatefulWidget {
  final CustomerModel customer;

  const CustomerForm2({Key? key, required this.customer}) : super(key: key);

  @override
  State<CustomerForm2> createState() => _CustomerForm2State();
}

class _CustomerForm2State extends State<CustomerForm2> {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button & title
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

                      // Header banner
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
                              Icon(Icons.directions_car, size: 24, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Vehicle & Gender',
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

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildLabel("Vehicle registration number"),
                            buildTextField(
                              hint: "e.g. 1234-AB",
                              icon: Icons.directions_car_filled,
                              controller: vehicleRegController,
                              validator: (value) =>
                              value == null || value.isEmpty ? "This field is required" : null,
                            ),
                            buildLabel("Vehicle code"),
                            buildTextField(
                              hint: "e.g. VH-568",
                              icon: Icons.code,
                              controller: vehicleCodeController,
                              validator: (value) =>
                              value == null || value.isEmpty ? "This field is required" : null,
                            ),
                            buildLabel("Gender"),
                            buildGenderDropdown(),
                          ],
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
                              vehicleRegController.clear();
                              vehicleCodeController.clear();
                              setState(() {
                                selectedGender = null;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Form cleared.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate() && selectedGender != null) {
                                CustomerModel updatedCustomer = widget.customer.copyWith(
                                  vehicleReg: vehicleRegController.text,
                                  vehicleCode: vehicleCodeController.text,
                                  gender: selectedGender!,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerForm3(customer: updatedCustomer),
                                  ),
                                );
                              } else if (selectedGender == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Please select a gender")),
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
            );
          },
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
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

  Widget buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        items: ['femme', 'homme'].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.wc, color: Colors.black54),
          hintText: "Select gender",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            selectedGender = value;
          });
        },
        validator: (_) => selectedGender == null ? 'Please select a gender' : null,
      ),
    );
  }
}
