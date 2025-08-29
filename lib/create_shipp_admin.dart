import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentFormStyledPage extends StatefulWidget {
  const ShipmentFormStyledPage({super.key});

  @override
  State<ShipmentFormStyledPage> createState() => _ShipmentFormStyledPageState();
}

class Package {
  TextEditingController description = TextEditingController();
  TextEditingController quantity = TextEditingController(text: "1");
  TextEditingController additionalCharge = TextEditingController(text: "0");
  TextEditingController declaredValue = TextEditingController(text: "0");
  TextEditingController weight = TextEditingController(text: "1");
  TextEditingController length = TextEditingController(text: "1");
  TextEditingController width = TextEditingController(text: "1");
  TextEditingController height = TextEditingController(text: "1");
}

class _ShipmentFormStyledPageState extends State<ShipmentFormStyledPage> {
  final _formKey = GlobalKey<FormState>();

  final totalValue = TextEditingController();
  final totalPrice = TextEditingController();
  final Map<String, TextEditingController> controllers = {};

  List<Package> packages = [];
  List<XFile> attachedFiles = [];// new uploads
  List<String> savedFileNames = [];// from Firestore


  List<String> trackingNumbers = [];
  String? selectedTracking;
  Map<String, dynamic>? shipmentData;
  Map<String, dynamic>? clientData;
  Map<String, dynamic>? recipientData;
  List<Map<String, dynamic>> drivers = [];
  String? selectedDriver;
  String? selectedShipmentDocId;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _addPackage(); // default package if no packages exist yet
    _loadTrackingNumbers();
    _loadDrivers();
  }

  void _initControllers() {
    controllers['receiverName'] = TextEditingController();
    controllers['address'] = TextEditingController();
    controllers['logisticsService'] = TextEditingController();
    controllers['courierCompany'] = TextEditingController();
    controllers['deliveryTime'] = TextEditingController();
    controllers['deliveryStatus'] = TextEditingController();
    controllers['driver'] = TextEditingController();
    controllers['senderName'] = TextEditingController();
    controllers['senderAddress'] = TextEditingController();
  }

  Future<void> _loadDrivers() async {
    final snapshot = await FirebaseFirestore.instance.collection('drivers').get();
    setState(() {
      drivers = snapshot.docs.map((doc) {
        final firstName = doc['firstName'] ?? '';
        final lastName = doc['lastName'] ?? '';
        final address = doc['addresses']?[0]?['address'] ?? '';
        return {
          'label': "$address-$lastName",
          'name': "$firstName $lastName",
          'address': address,
          'id': doc.id,
        };
      }).toList();
    });
  }

  Future<void> _loadTrackingNumbers() async {
    final snapshot = await FirebaseFirestore.instance.collection('shipments').get();
    setState(() {
      trackingNumbers = snapshot.docs
          .map((doc) => doc['trackingNumber']?.toString() ?? "")
          .where((e) => e.isNotEmpty)
          .toList();
    });
  }

  Future<void> _onSelectShipment(String tracking) async {
    setState(() {
      selectedTracking = tracking;
      shipmentData = null;
      clientData = null;
      recipientData = null;
      packages.clear();
      attachedFiles.clear();
    });

    final snap = await FirebaseFirestore.instance
        .collection('shipments')
        .where('trackingNumber', isEqualTo: tracking)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      final data = doc.data();
      setState(() {
        shipmentData = data;
        selectedShipmentDocId = doc.id;
      });

      // Load client data
      if (data['clientId'] != null) {
        final clientSnap = await FirebaseFirestore.instance
            .collection('clients')
            .doc(data['clientId'])
            .get();
        if (clientSnap.exists) clientData = clientSnap.data();
      }

      // Load recipient data
      if (data['recipientId'] != null) {
        final recSnap = await FirebaseFirestore.instance
            .collection('clients')
            .doc(data['recipientId'])
            .get();
        if (recSnap.exists) recipientData = recSnap.data();
      }

      // Initialize controllers
      controllers['receiverName']!.text = shipmentData?['receiverName'] ?? "";
      controllers['address']!.text = shipmentData?['address'] ?? "";
      controllers['logisticsService']!.text = shipmentData?['logisticsService'] ?? "";
      controllers['courierCompany']!.text = shipmentData?['courierCompany'] ?? "";
      controllers['deliveryTime']!.text = shipmentData?['deliveryTime'] ?? "";
      controllers['deliveryStatus']!.text = shipmentData?['deliveryStatus'] ?? "";
      controllers['driver']!.text = shipmentData?['driver'] ?? "";
      controllers['senderName']!.text = clientData?['firstName'] ?? '';
      controllers['senderAddress']!.text = clientData?['addresses']?[0]?['address'] ?? '';

      selectedDriver = shipmentData?['driver'];

      // Load packages from shipmentData
      if (shipmentData?['packages'] != null) {
        packages = [];
        for (var p in shipmentData!['packages']) {
          final pkg = Package();
          pkg.description.text = p['description'] ?? "";
          pkg.quantity.text = (p['quantity'] ?? 1).toString();
          pkg.additionalCharge.text = (p['additionalCharge'] ?? 0).toString();
          pkg.declaredValue.text = (p['declaredValue'] ?? 0).toString();
          pkg.weight.text = (p['weight'] ?? 1).toString();
          pkg.length.text = (p['length'] ?? 1).toString();
          pkg.width.text = (p['width'] ?? 1).toString();
          pkg.height.text = (p['height'] ?? 1).toString();
          pkg.quantity.addListener(_calculateTotals);
          pkg.declaredValue.addListener(_calculateTotals);
          pkg.additionalCharge.addListener(_calculateTotals);
          packages.add(pkg);
        }
      } else {
        _addPackage(); // fallback to at least one package
      }

      // Load attached files
      // Load attached files from Firestore
      if (shipmentData?['files'] != null) {
        savedFileNames = List<String>.from(shipmentData!['files']);
      }

      _calculateTotals();
    }
  }

  void _addPackage() {
    final pkg = Package();
    pkg.quantity.addListener(_calculateTotals);
    pkg.declaredValue.addListener(_calculateTotals);
    pkg.additionalCharge.addListener(_calculateTotals);
    packages.add(pkg);
    setState(() {});
  }

  void _removePackage(int index) {
    packages.removeAt(index);
    _calculateTotals();
    setState(() {});
  }

  void _calculateTotals() {
    double totalVal = 0;
    double totalPr = 0;
    for (var pkg in packages) {
      final q = int.tryParse(pkg.quantity.text) ?? 0;
      final val = double.tryParse(pkg.declaredValue.text) ?? 0;
      final add = double.tryParse(pkg.additionalCharge.text) ?? 0;
      totalVal += q * val;
      totalPr += q * add;
    }
    totalValue.text = totalVal.toStringAsFixed(2);
    totalPrice.text = totalPr.toStringAsFixed(2);
  }

  Future<void> _pickFiles() async {
    final typeGroup = XTypeGroup(label: 'documents', extensions: ['pdf', 'jpg', 'png']);
    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isNotEmpty) {
      setState(() {
        attachedFiles.addAll(files);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${files.length} file(s) added')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      attachedFiles.removeAt(index);
    });
  }

  @override
  void dispose() {
    totalValue.dispose();
    totalPrice.dispose();
    for (var pkg in packages) {
      pkg.description.dispose();
      pkg.quantity.dispose();
      pkg.additionalCharge.dispose();
      pkg.declaredValue.dispose();
      pkg.weight.dispose();
      pkg.length.dispose();
      pkg.width.dispose();
      pkg.height.dispose();
    }
    for (var c in controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _saveShipment() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedTracking == null || shipmentData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an existing shipment to edit."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = Timestamp.now();

    final packageList = packages.map((pkg) => {
      "description": pkg.description.text,
      "quantity": int.tryParse(pkg.quantity.text) ?? 1,
      "additionalCharge": double.tryParse(pkg.additionalCharge.text) ?? 0,
      "declaredValue": double.tryParse(pkg.declaredValue.text) ?? 0,
      "weight": double.tryParse(pkg.weight.text) ?? 1,
      "length": double.tryParse(pkg.length.text) ?? 1,
      "width": double.tryParse(pkg.width.text) ?? 1,
      "height": double.tryParse(pkg.height.text) ?? 1,
    }).toList();

    // Merge saved files from Firestore with newly attached ones
    final fileNames = [
      ...savedFileNames,                  // already in Firestore
      ...attachedFiles.map((f) => f.name) // new uploads
    ];


    final updatedShipment = {
      "address": controllers['address']!.text,
      "receiverName": controllers['receiverName']!.text,
      "city": shipmentData?['city'] ?? "Casablanca",
      "phone": clientData?['phone'] ?? "0123456789",
      "packages": packageList,
      "totalValue": double.tryParse(totalValue.text) ?? 0,
      "totalPrice": double.tryParse(totalPrice.text) ?? 0,
      "price": totalPrice.text,
      "dontAuthorize": shipmentData?['dontAuthorize'] ?? false,
      "files": fileNames,
      "logisticsService": controllers['logisticsService']!.text,
      "courierCompany": controllers['courierCompany']!.text,
      "deliveryTime": controllers['deliveryTime']!.text,
      "deliveryStatus": controllers['deliveryStatus']!.text,
      "driverId": selectedDriver != null
          ? drivers.firstWhere((d) => d['label'] == selectedDriver)['id']
          : shipmentData?['driverId'],
      "agencyList": shipmentData?['agencyList'],
      "originOffice": shipmentData?['originOffice'],
      "updatedAt": now,
    };

    try {
      await FirebaseFirestore.instance
          .collection('shipments')
          .doc(selectedShipmentDocId)
          .update(updatedShipment);

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                const SizedBox(height: 12),
                const Text(
                  "Shipment updated successfully!",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("OK"),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Error updating shipment: $e"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))
          ],
        ),
      );
    }
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Shipment"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Shipment Header
              _buildCard("Shipment Header", Icons.local_shipping, [
                _responsiveRow([
                  _dropdownTrackingField("Order Number", trackingNumbers),
                  _safeDropdown(
                      label: "Agency List",
                      items: ["YanShip Group"],
                      value: shipmentData?['agencyList'],
                      onChanged: (val) {
                        setState(() {
                          shipmentData?['agencyList'] = val;
                        });
                      }),
                  _safeDropdown(
                      label: "Origin Office",
                      items: ["Ben Mellal", "Casablanca", "Dakhla", "Fes", "Marrakech", "Oujda"],
                      value: shipmentData?['originOffice'],
                      onChanged: (val) {
                        setState(() {
                          shipmentData?['originOffice'] = val;
                        });
                      }),
                ], isMobile),
              ]),

              // Sender + Recipient
              _responsiveRow([
                Expanded(
                  child: _buildCard("Sender Information", Icons.person, [
                    _textField(
                      "Sender/Customer",
                      controllers['senderName']!,
                      readOnly: true,
                    ),
                    _textField(
                      "Sender Address",
                      controllers['senderAddress']!,
                      readOnly: true,
                    ),
                  ]),
                ),
                Expanded(
                  child: _buildCard("Recipient Information", Icons.person_pin, [
                    _textField(
                      "Recipient/Customer",
                      controllers['receiverName']!,
                      readOnly: (shipmentData?['receiverName'] ?? "").toString().isNotEmpty,
                    ),
                    _textField(
                      "Recipient Address",
                      controllers['address']!,
                      readOnly: (shipmentData?['address'] ?? "").toString().isNotEmpty,
                    ),
                  ]),
                ),
              ], isMobile),

              // Shipment Info
              _buildCard("Shipment Info", Icons.inventory, [
                _responsiveRow([
                  _safeDropdown(
                      label: "Logistics Service",
                      items: ["Road Freight", "Air Freight"],
                      value: controllers['logisticsService']!.text,
                      onChanged: (val) {
                        setState(() {
                          controllers['logisticsService']!.text = val ?? "";
                        });
                      },
                      small: isMobile),
                  _safeDropdown(
                      label: "Courier Company",
                      items: ["YanShip"],
                      value: controllers['courierCompany']!.text,
                      onChanged: (val) {
                        setState(() {
                          controllers['courierCompany']!.text = val ?? "";
                        });
                      },
                      small: isMobile),
                ], isMobile),
                _responsiveRow([
                  _safeDropdown(
                      label: "Delivery Time",
                      items: ["Next Day", "Same Day"],
                      value: controllers['deliveryTime']!.text,
                      onChanged: (val) {
                        setState(() {
                          controllers['deliveryTime']!.text = val ?? "";
                        });
                      },
                      small: isMobile),
                  _safeDropdown(
                      label: "Delivery Status",
                      items: [
                        "Created",
                        "In Transit",
                        "Cancelled",
                        "Confirm",
                        "Distribution",
                        "In Warehouse",
                        "No answer",
                        "Picked up",
                        "Pickup",
                        "Rejected",
                        "Reported",
                        "Retrieve",
                        "Returned"
                      ],
                      value: controllers['deliveryStatus']!.text,
                      onChanged: (val) {
                        setState(() {
                          controllers['deliveryStatus']!.text = val ?? "";
                        });
                      },
                      small: isMobile),
                ], isMobile),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(attachedFiles.isEmpty
                        ? "Attach Files"
                        : "${attachedFiles.length} file(s) attached"),
                    onPressed: _pickFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                // New files not yet saved
                if (attachedFiles.isNotEmpty)
                  Column(
                    children: List.generate(attachedFiles.length, (index) {
                      final file = attachedFiles[index];
                      return ListTile(
                        title: Text(file.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFile(index),
                        ),
                      );
                    }),
                  ),

// Already saved files from Firestore
                if (savedFileNames.isNotEmpty)
                  Column(
                    children: List.generate(savedFileNames.length, (index) {
                      final fileName = savedFileNames[index];
                      return ListTile(
                        title: Text(fileName),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              savedFileNames.removeAt(index);
                            });
                          },
                        ),
                      );
                    }),
                  ),

              ]),

              // Package Info
              _buildCard("Package Info", Icons.inbox, [
                Column(
                  children: List.generate(packages.length, (index) {
                    final pkg = packages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _responsiveRow([
                          Expanded(flex: 3, child: _textField("Description", pkg.description, small: isMobile)),
                          Expanded(flex: 1, child: _textField("Quantity", pkg.quantity, isNumber: true, small: isMobile)),
                          Expanded(flex: 1, child: _textField("Additional charge", pkg.additionalCharge, isNumber: true, small: isMobile)),
                          Expanded(flex: 1, child: _textField("Declared value", pkg.declaredValue, isNumber: true, small: isMobile)),
                          if (index != 0)
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                onPressed: () => _removePackage(index),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ),
                        ], isMobile),

                        const SizedBox(height: 8),
                        _responsiveRow([
                          Expanded(child: _textField("Weight", pkg.weight, isNumber: true, small: isMobile)),
                          Expanded(child: _textField("Length", pkg.length, isNumber: true, small: isMobile)),
                          Expanded(child: _textField("Width", pkg.width, isNumber: true, small: isMobile)),
                          Expanded(child: _textField("Height", pkg.height, isNumber: true, small: isMobile)),
                        ], isMobile),
                        const SizedBox(height: 8),
                        if (index != packages.length - 1) const Divider(),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Boxes or Packages"),
                    onPressed: _addPackage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _responsiveRow([
                  _textField("Total Value", totalValue, readOnly: true, isNumber: true, small: isMobile),
                  _textField("Total Price", totalPrice, readOnly: true, isNumber: true, small: isMobile),
                ], isMobile),
              ]),

              // Driver
              _buildCard("Assign Driver", Icons.drive_eta, [
                _responsiveRow([
                  Flexible(
                    child: SizedBox(
                      width: isMobile ? double.infinity : 250,
                      child: _safeDropdown(
                        label: "Driver",
                        items: drivers.map((d) => d['label']?.toString() ?? "").toList(),
                        value: selectedDriver,
                        onChanged: (val) {
                          setState(() {
                            selectedDriver = val;
                          });
                        },
                        small: isMobile,
                      ),
                    ),
                  ),
                ], isMobile),
              ]),

              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Create New Shipment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  onPressed: _saveShipment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ Helpers ------------------

  Widget _responsiveRow(List<Widget> children, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map((w) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: w,
        ))
            .toList(),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((w) => Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: w,
          ),
        ))
            .toList(),
      );
    }
  }

  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.greenAccent),
                const SizedBox(width: 6),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {bool isNumber = false, bool readOnly = false, bool small = false, int flex = 1}) {
    return SizedBox(
      height: small ? 40 : 50,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade100,
        ),
        validator: (val) => val == null || val.isEmpty ? "Enter $label" : null,
        onChanged: (_) => _calculateTotals(),
      ),
    );
  }

  Widget _safeDropdown({required String label, required List<String> items, String? value, bool small = false, Function(String?)? onChanged}) {
    final filteredItems = items.where((e) => e.isNotEmpty).toSet().toList();
    final safeValue = (value != null && filteredItems.contains(value)) ? value : null;
    return SizedBox(
      height: small ? 40 : 50,
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: filteredItems
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(
            e,
            overflow: TextOverflow.ellipsis,
          ),
        ))
            .toList(),
        onChanged: onChanged,
        validator: (val) => (filteredItems.isNotEmpty && val == null) ? "Select $label" : null,
      ),
    );
  }

  Widget _dropdownTrackingField(String label, List<String> items) {
    final filteredItems = items.where((e) => e.isNotEmpty).toSet().toList();
    final safeValue = (selectedTracking != null && filteredItems.contains(selectedTracking))
        ? selectedTracking
        : null;
    return SizedBox(
      height: 50,
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: filteredItems.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) {
          if (val != null) _onSelectShipment(val);
        },
        validator: (val) => val == null ? "Select $label" : null,
      ),
    );
  }
}
