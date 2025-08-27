import 'package:flutter/material.dart';

class ShipmentFormStyledPage extends StatefulWidget {
  const ShipmentFormStyledPage({super.key});

  @override
  State<ShipmentFormStyledPage> createState() => _ShipmentFormStyledPageState();
}

class _ShipmentFormStyledPageState extends State<ShipmentFormStyledPage> {
  final _formKey = GlobalKey<FormState>();

  // Example controllers
  final trackingNumber = TextEditingController(text: "000010");
  final description = TextEditingController();
  final quantity = TextEditingController(text: "1");
  final valueAssured = TextEditingController(text: "100");
  final pricePerKg = TextEditingController(text: "3");

  String? logisticsService;
  String? courierCompany;
  String? shippingMode;
  String? sender;
  String? recipient;
  String? driver;

  @override
  Widget build(BuildContext context) {
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
              _buildCard("Shipment Header", Icons.local_shipping, [
                _buildRow([
                  _textField("Order Number", trackingNumber),
                  _dropdownField("Agency List", ["YanShip Group"]),
                  _dropdownField("Origin Office", ["Ben Mellal"]),
                ]),
              ]),
              _buildCard("Sender Information", Icons.person, [
                _dropdownField("Sender/Customer", ["Customer A", "Customer B"]),
                _dropdownField("Sender Address", ["Address 1", "Address 2"]),
              ]),
              _buildCard("Recipient Information", Icons.person_pin, [
                _dropdownField(
                    "Recipient/Customer", ["Customer C", "Customer D"]),
                _dropdownField("Recipient Address", ["Address 3", "Address 4"]),
              ]),
              _buildCard("Shipment Info", Icons.inventory, [
                _buildRow([
                  _dropdownField("Logistics Service",
                      ["Road Freight", "Air Freight", "Sea Freight"]),
                  _dropdownField("Courier Company", ["YanShip"]),
                ]),
                _buildRow([
                  _dropdownField("Shipping Mode", ["Next Day", "Express"]),
                  _dropdownField("Delivery Time", ["Transit", "Standard"]),
                ]),
                _buildRow([
                  _dropdownField("Payment Method", ["Cash", "Credit"]),
                  _dropdownField("Delivery Status", ["Created", "In Transit"]),
                ]),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Files"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600),
                ),
              ]),
              _buildCard("Package Info", Icons.inbox, [
                _textField("Description", description),
                _buildRow([
                  _textField("Quantity", quantity, isNumber: true),
                  _textField("Value Assured", valueAssured, isNumber: true),
                ]),
                _textField("Price/Kg", pricePerKg, isNumber: true),
              ]),
              _buildCard("Assign Driver", Icons.drive_eta, [
                _dropdownField("Driver", ["Driver 1", "Driver 2"]),
              ]),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text("Create New Shipment"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Shipment Created!")));
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

  // Section card with colored header
  Widget _buildCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.greenAccent),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        validator: (val) =>
        val == null || val.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (val) {},
        validator: (val) => val == null ? "Select $label" : null,
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .map((w) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: w,
          )))
          .toList(),
    );
  }
}
