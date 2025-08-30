import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _t(String key, String lang) {
  switch (lang) {
    case 'fr':
      return {
        "edit_shipment": "Modifier l'expédition",
        "add_shipment": "Ajouter une nouvelle expédition",
        "city": "Ville",
        "receiver_name": "Nom du destinataire",
        "address": "Adresse",
        "phone": "Téléphone",
        "price": "Prix",
        "dont_authorize": "Ne pas autoriser l'ouverture du colis",
        "update_order": "Mettre à jour la commande",
        "add_order": "Ajouter la commande",
        "required": "Champ obligatoire",
        "invalid_phone": "Le téléphone doit contenir exactement 10 chiffres",
        "invalid_price": "Le prix doit contenir uniquement des chiffres",
        "invalid_email": "Email invalide",
        "success_update": "Expédition mise à jour avec succès !",
        "success_add": "Expédition ajoutée avec succès !",
        "user_not_logged": "Utilisateur non connecté",
        "failed_load": "Échec du chargement des données d'expédition",
      }[key] ?? key;

    case 'ar':
      return {
        "edit_shipment": "تعديل الشحنة",
        "add_shipment": "إضافة شحنة جديدة",
        "city": "المدينة",
        "receiver_name": "اسم المستلم",
        "address": "العنوان",
        "phone": "الهاتف",
        "price": "السعر",
        "dont_authorize": "عدم السماح بفتح الطرد",
        "update_order": "تحديث الطلب",
        "add_order": "إضافة الطلب",
        "required": "هذا الحقل مطلوب",
        "invalid_phone": "يجب أن يحتوي الهاتف على 10 أرقام",
        "invalid_price": "يجب أن يحتوي السعر على أرقام فقط",
        "invalid_email": "البريد الإلكتروني غير صالح",
        "success_update": "تم تحديث الشحنة بنجاح!",
        "success_add": "تمت إضافة الشحنة بنجاح!",
        "user_not_logged": "المستخدم غير مسجل الدخول",
        "failed_load": "فشل تحميل بيانات الشحنة",
      }[key] ?? key;

    default:
      return {
        "edit_shipment": "Edit shipment",
        "add_shipment": "Add new shipment",
        "city": "City",
        "receiver_name": "Receiver Name",
        "address": "Address",
        "phone": "Phone",
        "price": "Price",
        "dont_authorize": "Don't Authorize to open box",
        "update_order": "UPDATE ORDER",
        "add_order": "ADD NEW ORDER",
        "required": "This field is required",
        "invalid_phone": "Phone must be exactly 10 digits",
        "invalid_price": "Price must contain only numbers",
        "invalid_email": "Invalid email",
        "success_update": "Shipment updated successfully!",
        "success_add": "Shipment added successfully!",
        "user_not_logged": "User not logged in",
        "failed_load": "Failed to load shipment data",
      }[key] ?? key;
  }
}

class AddShipmentScreen extends StatefulWidget {
  final String? shipmentId;
  final String currentLang;

  const AddShipmentScreen({Key? key, this.shipmentId, this.currentLang = 'en'})
      : super(key: key);

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
  bool isEditMode = false;
  bool isLoading = false;

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
        SnackBar(content: Text("${_t("failed_load", widget.currentLang)}: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitShipment() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";

    try {
      if (isEditMode) {
        // Just update editable fields
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
          SnackBar(
            content: Text(_t("success_update", widget.currentLang)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Generate tracking number format: AWB0000001, AWB0000002, ...
        final counterRef = FirebaseFirestore.instance.collection('counters').doc('shipments');
        final counterSnap = await counterRef.get();

        int nextNumber = 1;
        if (counterSnap.exists) {
          nextNumber = (counterSnap.data()!['lastNumber'] ?? 0) + 1;
        }

        await counterRef.set({'lastNumber': nextNumber}, SetOptions(merge: true));
        final trackingNumber = 'AWB${nextNumber.toString().padLeft(7, '0')}';

        final shipmentData = {
          // --- existing fields ---
          'city': selectedCity,
          'receiverName': receiverNameController.text.trim(),
          'address': addressController.text.trim(),
          'phone': phoneController.text.trim(),
          'price': priceController.text.trim(),
          'dontAuthorize': dontAuthorize,
          'clientId': userId,
          'driverId': null,
          'status': 'created',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),

          // --- new hidden fields ---
          'trackingNumber': trackingNumber,
          'agencyList': null,
          'originOffice': null,
          'logisticsService': null,
          'deliveryTime': null,
          'courierCompany': null,
          'deliveryStatus': null,
          'secondAdminValue': null,

          // Packages: list of maps (empty at first)
          'packages': [],

          // Totals
          'totalValue': 0,
          'totalPrice': 0,

          // Files: list of strings (empty at first)
          'files': [],
        };

        await FirebaseFirestore.instance.collection('shipments').add(shipmentData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t("success_add", widget.currentLang)),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 3)),
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
                        isEditMode
                            ? _t("edit_shipment", widget.currentLang)
                            : _t("add_shipment", widget.currentLang),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildLabeledDropdown('city', cityOptions),
                        const SizedBox(height: 15),
                        buildLabeledField('receiver_name', receiverNameController),
                        const SizedBox(height: 15),
                        buildLabeledField('address', addressController),
                        const SizedBox(height: 15),
                        buildLabeledField('phone', phoneController, TextInputType.phone),
                        const SizedBox(height: 15),
                        buildLabeledField('price', priceController, TextInputType.number),
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
                            Text(_t("dont_authorize", widget.currentLang)),
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
                              isEditMode ? _t("update_order", widget.currentLang) : _t("add_order", widget.currentLang),
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

  Widget buildLabeledField(String fieldKey, TextEditingController controller,
      [TextInputType inputType = TextInputType.text]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t(fieldKey, widget.currentLang),
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return _t("required", widget.currentLang);

            if (fieldKey == 'phone' && !RegExp(r'^\d{10}$').hasMatch(value)) {
              return _t("invalid_phone", widget.currentLang);
            }

            if (fieldKey == 'price' && !RegExp(r'^\d+$').hasMatch(value)) {
              return _t("invalid_price", widget.currentLang);
            }

            // Example for email validation if needed
            if (fieldKey == 'email' &&
                !RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value)) {
              return _t("invalid_email", widget.currentLang);
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: _t(fieldKey, widget.currentLang),
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

  Widget buildLabeledDropdown(String fieldKey, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t(fieldKey, widget.currentLang),
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedCity ?? items.first,
          validator: (value) {
            if (value == null || value == 'Value' || value.startsWith('--')) {
              return _t("required", widget.currentLang);
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
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
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
