import 'package:flutter/material.dart';
import 'customer_form4.dart';
import 'models/customer_model.dart';

class CustomerForm3 extends StatefulWidget {
  final CustomerModel customer;

  const CustomerForm3({super.key, required this.customer});

  @override
  State<CustomerForm3> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<CustomerForm3> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, TextEditingController>> addressList = [];

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
                                Icon(Icons.location_on, color: Colors.blue),
                                SizedBox(width: 10),
                                Text(
                                  'Address Info',
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

                        // Dynamic Address List
                        ...List.generate(addressList.length, (index) {
                          final address = addressList[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Address ${index + 1}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              buildLabel("Address"),
                              buildTextField(
                                controller: address['address']!,
                                hint: "123 Main Street",
                                icon: Icons.home_outlined,
                              ),
                              buildLabel("Country"),
                              buildTextField(
                                controller: address['country']!,
                                hint: "Morocco",
                                icon: Icons.flag_outlined,
                              ),
                              buildLabel("City"),
                              buildTextField(
                                controller: address['city']!,
                                hint: "Casablanca",
                                icon: Icons.location_city,
                              ),
                              buildLabel("Zip Code"),
                              buildTextField(
                                controller: address['zip']!,
                                hint: "20000",
                                keyboardType: TextInputType.number,
                                icon: Icons.numbers_outlined,
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        }),

                        // Add another address
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: addNewAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.add),
                            label: Text("Add another address"),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Navigation Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                _formKey.currentState!.reset();
                                for (var address in addressList) {
                                  address.values.forEach((c) => c.clear());
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Form cleared."),
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
                                if (_formKey.currentState!.validate()) {
                                  List<Map<String, dynamic>> addresses = addressList.map((addr) {
                                    return {
                                      'address': addr['address']!.text,
                                      'country': addr['country']!.text,
                                      'city': addr['city']!.text,
                                      'zip': addr['zip']!.text,
                                    };
                                  }).toList();

                                  CustomerModel updatedCustomer = widget.customer.copyWith(
                                    addresses: addresses,
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => customer_form4(customer: updatedCustomer),
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
                              child: Text("Next", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
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

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6),
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
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}
