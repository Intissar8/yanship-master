import 'package:flutter/material.dart';
import 'customer_form4.dart';
import 'models/customer_model.dart'; // Make sure this is correct

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
    addNewAddress(); // Add initial address block
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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text('Add Customer',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Address Forms
                ...List.generate(addressList.length, (index) {
                  final address = addressList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Address ${index + 1}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 10),
                      buildLabel("Address"),
                      buildTextField(controller: address['address']!, hint: "Address"),
                      buildLabel("Country"),
                      buildTextField(controller: address['country']!, hint: "Country"),
                      buildLabel("City"),
                      buildTextField(controller: address['city']!, hint: "City"),
                      buildLabel("Zip Code"),
                      buildTextField(
                        controller: address['zip']!,
                        hint: "Zip code",
                        keyboardType: TextInputType.number,
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
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(Icons.add),
                    label: Text("Add another address", style: TextStyle(color: Colors.white)),
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
                        for (var address in addressList) {
                          address.values.forEach((c) => c.clear());
                        }
                      },
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
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: Text("Next", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 5),
      child: Text(text, style: TextStyle(fontStyle: FontStyle.italic)),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
      value == null || value.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
    );
  }
}
