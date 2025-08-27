import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

class ShipmentFormStyledPage extends StatefulWidget {
  const ShipmentFormStyledPage({super.key});

  @override
  State<ShipmentFormStyledPage> createState() =>
      _ShipmentFormStyledPageState();
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

  // Controllers
  final trackingNumber = TextEditingController();
  final totalValue = TextEditingController();
  final totalPrice = TextEditingController();

  List<Package> packages = [];
  List<XFile> attachedFiles = [];

  @override
  void initState() {
    super.initState();
    trackingNumber.text = DateTime.now().millisecondsSinceEpoch.toString();
    _addPackage(); // Start with one package
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
    final typeGroup = XTypeGroup(
        label: 'documents', extensions: ['pdf', 'jpg', 'png']);
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
    trackingNumber.dispose();
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
    super.dispose();
  }

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
                  _textField("Order Number", trackingNumber,
                      readOnly: true, small: isMobile),
                  _dropdownField("Agency List", ["YanShip Group"],
                      small: isMobile),
                  _dropdownField("Origin Office", [
                    "Ben Mellal",
                    "Casablanca",
                    "Dakhla",
                    "Fes",
                    "Marrakech",
                    "Oujda"
                  ], small: isMobile),
                ], isMobile),
              ]),

              // Sender + Recipient Information
              _responsiveRow([
                Expanded(
                  child: _buildCard(
                    "Sender Information",
                    Icons.person,
                    [
                      _dropdownField(
                          "Sender/Customer", ["Customer A", "Customer B"],
                          small: isMobile),
                      _dropdownField("Sender Address",
                          ["Address 1", "Address 2"],
                          small: isMobile),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildCard(
                    "Recipient Information",
                    Icons.person_pin,
                    [
                      _dropdownField("Recipient/Customer",
                          ["Customer C", "Customer D"],
                          small: isMobile),
                      _dropdownField("Recipient Address",
                          ["Address 3", "Address 4"],
                          small: isMobile),
                    ],
                  ),
                ),
              ], isMobile),

              // Shipment Info
              _buildCard("Shipment Info", Icons.inventory, [
                _responsiveRow([
                  _dropdownField("Logistics Service",
                      ["Road Freight", "Air Freight"],
                      small: isMobile),
                  _dropdownField("Courier Company", ["YanShip"],
                      small: isMobile),
                ], isMobile),
                _responsiveRow([
                  _dropdownField("Delivery Time",
                      ["Next Day", "Same Day"],
                      small: isMobile),
                  _dropdownField("Delivery Status", [
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
                  ], small: isMobile),
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
                if (attachedFiles.isNotEmpty)
                  Column(
                    children: List.generate(attachedFiles.length, (index) {
                      final file = attachedFiles[index];
                      return ListTile(
                        title: Text(file.name),
                        trailing: IconButton(
                          icon:
                          const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFile(index),
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
                          _textField("Description", pkg.description,
                              small: isMobile, flex: 3),
                          _textField("Quantity", pkg.quantity,
                              isNumber: true, small: isMobile, flex: 1),
                          _textField("Additional charge",
                              pkg.additionalCharge,
                              isNumber: true, small: isMobile, flex: 1),
                          _textField("Declared value", pkg.declaredValue,
                              isNumber: true, small: isMobile, flex: 1),
                          if (index != 0)
                            IconButton(
                              onPressed: () => _removePackage(index),
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                            ),
                        ], isMobile),
                        const SizedBox(height: 8),
                        _responsiveRow([
                          _textField("Weight", pkg.weight,
                              isNumber: true, small: isMobile),
                          _textField("Length", pkg.length,
                              isNumber: true, small: isMobile),
                          _textField("Width", pkg.width,
                              isNumber: true, small: isMobile),
                          _textField("Height", pkg.height,
                              isNumber: true, small: isMobile),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _responsiveRow([
                  _textField("Total Value", totalValue,
                      readOnly: true, isNumber: true, small: isMobile),
                  _textField("Total Price", totalPrice,
                      readOnly: true, isNumber: true, small: isMobile),
                ], isMobile),
              ]),

              // Driver
              _buildCard("Assign Driver", Icons.drive_eta, [
                _dropdownField("Driver", ["Driver 1", "Driver 2"],
                    small: isMobile),
              ]),

              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Create New Shipment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Shipment Created Successfully!")));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers
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
        children: children
            .map((w) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 2),
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
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.greenAccent),
                const SizedBox(width: 6),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
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
      {bool isNumber = false,
        bool readOnly = false,
        bool small = false,
        int flex = 1}) {
    return SizedBox(
      height: small ? 40 : 50,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor:
          readOnly ? Colors.grey.shade200 : Colors.grey.shade100,
        ),
        validator: (val) =>
        val == null || val.isEmpty ? "Enter $label" : null,
        onChanged: (_) => _calculateTotals(),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items,
      {bool small = false}) {
    return SizedBox(
      height: small ? 40 : 50,
      child: DropdownButtonFormField<String>(
        isDense: true,
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: items
            .map((e) =>
            DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {},
        validator: (val) => val == null ? "Select $label" : null,
      ),
    );
  }
}
