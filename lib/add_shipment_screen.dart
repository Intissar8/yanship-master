import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddShipmentScreen extends StatefulWidget {
  final String? shipmentId; // null = création

  const AddShipmentScreen({Key? key, this.shipmentId}) : super(key: key);

  @override
  State<AddShipmentScreen> createState() => _AddShipmentScreenState();
}

class _AddShipmentScreenState extends State<AddShipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedCity;
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  bool dontAuthorize = false;

  final List<String> cityOptions = [
    'Value',
    '-- Grand Casablanca --',
    'Casablanca',
    'Mohammedia',
    'El Jadida',
    '-- Rabat-Salé-Kénitra --',
    'Rabat',
    'Salé',
    'Kénitra',
    '-- Fès-Meknès --',
    'Fès',
    'Meknès',
    'Ifrane',
    '-- Marrakech-Safi --',
    'Marrakech',
    'Safi',
    'Essaouira',
    '-- Tanger-Tétouan-Al Hoceïma --',
    'Tanger',
    'Tétouan',
    'Al Hoceïma',
    '-- Souss-Massa --',
    'Agadir',
    'Tiznit',
    '-- Oriental --',
    'Oujda',
    'Nador',
    'Berkane',
    '-- Béni Mellal-Khénifra --',
    'Béni Mellal',
    'Khouribga',
  ];

  bool isEditMode = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.shipmentId != null) {
      isEditMode = true;
      _loadShipmentData();
    }
  }

  Future<void> _loadShipmentData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('shipments')
          .doc(widget.shipmentId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          selectedCity = data['city'];
          receiverNameController.text = data['receiverName'] ?? '';
          addressController.text = data['address'] ?? '';
          phoneController.text = data['phone'] ?? '';
          priceController.text = data['price']?.toString() ?? '';
          dontAuthorize = data['dontAuthorize'] ?? false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load shipment data: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitShipment() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final shipmentData = {
      'city': selectedCity,
      'receiverName': receiverNameController.text.trim(),
      'address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      'price': priceController.text.trim(),
      'dontAuthorize': dontAuthorize,
      'clientId': user.uid,
      'driverId': null,
      'status': isEditMode ? FieldValue.delete() : 'created',
      'createdAt': isEditMode ? FieldValue.delete() : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {if (isEditMode) {
      // Update existant sans supprimer status ni createdAt
      await FirebaseFirestore.instance
          .collection('shipments')
          .doc(widget.shipmentId)
          .update({
        'city': selectedCity,
        'receiverName': receiverNameController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'price': priceController.text.trim(),
        'dontAuthorize': dontAuthorize,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shipment updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
    else {
      // Création
      await FirebaseFirestore.instance.collection('shipments').add(shipmentData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shipment added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.of(context).pop(); // Retour au dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        isEditMode ? 'Edit shipment' : 'Add new shipment',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildLabeledDropdown('City', cityOptions),
                        const SizedBox(height: 15),
                        buildLabeledField('Receiver Name', receiverNameController),
                        const SizedBox(height: 15),
                        buildLabeledField('Address', addressController),
                        const SizedBox(height: 15),
                        buildLabeledField('Phone', phoneController, TextInputType.phone),
                        const SizedBox(height: 15),
                        buildLabeledField('Price', priceController, TextInputType.number),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Checkbox(
                              value: dontAuthorize,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  dontAuthorize = value ?? false;
                                });
                              },
                            ),
                            const Text("Don't Authorize to open box"),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: submitShipment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              isEditMode ? 'UPDATE ORDER' : 'ADD NEW ORDER',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildLabeledField(String label, TextEditingController controller,
      [TextInputType inputType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            if (label == 'Phone' && !RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Phone must be exactly 10 digits';
            }
            if (label == 'Price' && !RegExp(r'^\d+$').hasMatch(value)) {
              return 'Price must contain only numbers';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLabeledDropdown(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedCity ?? items.first,
          validator: (value) {
            if (value == null || value == 'Value' || value.startsWith('--')) {
              return 'Please select a valid city';
            }
            return null;
          },
          items: items.map((city) {
            if (city.startsWith('--')) {
              return DropdownMenuItem<String>(
                enabled: false,
                value: city,
                child: Text(
                  city.replaceAll('--', '').trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            } else {
              return DropdownMenuItem<String>(
                value: city,
                child: Text(city),
              );
            }
          }).toList(),
          onChanged: (value) => setState(() => selectedCity = value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

