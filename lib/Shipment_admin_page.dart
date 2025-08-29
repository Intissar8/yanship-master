import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_shipp_admin.dart';

class ShipmentsTablePage extends StatefulWidget {
  const ShipmentsTablePage({super.key});

  @override
  State<ShipmentsTablePage> createState() => _ShipmentsTablePageState();
}

class _ShipmentsTablePageState extends State<ShipmentsTablePage> {
  List<Map<String, dynamic>> shipments = [];

  final Map<String, Color> statusColors = {
    "Created": Colors.blueGrey,          // Created shipments
    "In Transit": Colors.lightBlue,      // Shipments on the way
    "Cancelled": Colors.red,             // Cancelled shipments
    "Confirm": Colors.teal,              // Confirmed shipments
    "Distribution": Colors.deepPurple,   // Out for distribution
    "In Warehouse": Colors.brown,        // In warehouse
    "No answer": Colors.orange,          // No answer from customer
    "Picked up": Colors.lightGreen,      // Picked up
    "Pickup": Colors.indigo,             // Pickup status
    "Rejected": Colors.redAccent,        // Rejected shipments
    "Reported": Colors.amber,            // Reported issues
    "Retrieve": Colors.cyan,             // Retrieve shipments
    "Returned": Colors.purple,           // Returned shipments
    "Delivered": Colors.green,           // Delivered shipments
    "Driver Paid": Colors.tealAccent,    // Driver Paid
    "Customer Paid": Colors.indigoAccent,// Customer Paid
    "Driver Not Paid": Colors.orangeAccent,// Driver Not Paid
    "Customer Not Paid": Colors.redAccent,// Customer Not Paid
  };


  @override
  void initState() {
    super.initState();
    fetchShipments();
  }

  Future<void> fetchShipments() async {
    final snapshot = await FirebaseFirestore.instance.collection('shipments').get();

    final List<Map<String, dynamic>> tempList = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Extract sender safely
      final clientId = data['clientId'] as String?;
      final senderName = clientId != null ? await getClientName(clientId) : "-";

      // Extract driver safely
      final driverId = data['driverId'] as String?;
      final driverName = driverId != null ? await getDriverName(driverId) : "-";

      // Extract packages safely
      double fee = 0;
      if (data['packages'] != null && (data['packages'] as List).isNotEmpty) {
        fee = (data['packages'][0]['additionalCharge'] ?? 0).toDouble();
      }

      tempList.add({
        "id": doc.id, // store the Firestore document ID
        "sender": senderName,
        "driver": driverName,
        "receiver": data['receiverName']?.toString() ?? "-",
        "city": data['city']?.toString() ?? "-",
        "price": data['totalPrice']?.toString() ?? data['price']?.toString() ?? "-",
        "fee": fee.toString(),
        "status": data['deliveryStatus']?.toString() ?? "-",
        "statusColor": statusColors[data['deliveryStatus']] ?? Colors.grey,
        "selectedStatus": data['secondAdminValue']?.toString() ?? "",
      });
    }

    setState(() {
      shipments = tempList;
    });
  }


  Future<String> getClientName(String? clientId) async {
    if (clientId == null) return "-";
    final doc = await FirebaseFirestore.instance.collection('clients').doc(clientId).get();
    if (!doc.exists) return "-";
    final data = doc.data() ?? {};
    return "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
  }

  Future<String> getDriverName(String? driverId) async {
    if (driverId == null) return "-";
    final doc = await FirebaseFirestore.instance.collection('drivers').doc(driverId).get();
    if (!doc.exists) return "-";
    final data = doc.data() ?? {};
    return "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Shipments", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSearchBox("Search tracking", icon: Icons.search, width: 200),
                const SizedBox(width: 12),
                _buildDropdown(
                  hint: "-- Select shipping status --",
                  items: {
                    "Created": Icons.add_circle_outline,
                    "In Transit": Icons.local_shipping,
                    "Cancelled": Icons.cancel,
                    "Confirm": Icons.check_circle,
                    "Distribution": Icons.apartment,
                    "In Warehouse": Icons.warehouse,
                    "No answer": Icons.call_missed,
                    "Picked up": Icons.handshake,
                    "Pickup": Icons.store_mall_directory,
                    "Rejected": Icons.block,
                    "Reported": Icons.report,
                    "Retrieve": Icons.assignment_return,
                    "Returned": Icons.keyboard_return,
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShipmentFormStyledPage()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("Add Shipment", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 48,
                    dataRowHeight: 56,
                    headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    dataTextStyle: const TextStyle(color: Colors.black87),
                    dividerThickness: 0.6,
                    columns: const [
                      DataColumn(label: Text("Sender")),
                      DataColumn(label: Text("Driver")),
                      DataColumn(label: Text("Receiver")),
                      DataColumn(label: Text("City")),
                      DataColumn(label: Text("Price")),
                      DataColumn(label: Text("Fee")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("")),
                      DataColumn(label: Text("Options")),
                    ],
                    rows: List.generate(shipments.length, (index) => _buildRow(index)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(String hint, {IconData? icon, double? width}) {
    return SizedBox(
      width: width,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.lightBlue) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.lightBlue.shade100),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String hint, required Map<String, IconData> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightBlue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint, style: const TextStyle(color: Colors.black54)),
          items: items.entries
              .map((e) => DropdownMenuItem(
            value: e.key,
            child: Row(
              children: [
                Icon(e.value, size: 18, color: Colors.lightBlue.shade700),
                const SizedBox(width: 8),
                Text(e.key, style: const TextStyle(color: Colors.black)),
              ],
            ),
          ))
              .toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }

  DataRow _buildRow(int index) {
    final shipment = shipments[index];
    return DataRow(cells: [
      DataCell(Text(shipment["sender"] ?? "-")),
      DataCell(Text(shipment["driver"] ?? "-")),
      DataCell(Text(shipment["receiver"] ?? "-")),
      DataCell(Text(shipment["city"] ?? "-")),
      DataCell(Text(shipment["price"]?.toString() ?? "-")),
      DataCell(Text(shipment["fee"]?.toString() ?? "-")),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (statusColors[shipment["status"]] ?? Colors.grey).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          shipment["status"] ?? "-",
          style: TextStyle(
            color: statusColors[shipment["status"]] ?? Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      )),
      DataCell(shipment["selectedStatus"] == null || shipment["selectedStatus"] == ""
          ? const SizedBox()
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (statusColors[shipment["selectedStatus"]] ?? Colors.grey).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          shipment["selectedStatus"],
          style: TextStyle(
            color: statusColors[shipment["selectedStatus"]] ?? Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      )),
      DataCell(
        PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: const Icon(Icons.more_vert, color: Colors.black),
          itemBuilder: (context) => [
            _menuItem("Delivered", Icons.check_circle, Colors.green),
            _menuItem("Picked up", Icons.handshake, Colors.lightGreen),
            _menuItem("No answer", Icons.call_missed, Colors.orange),
            _menuItem("Reported", Icons.report, Colors.amber),
            _menuItem("Rejected", Icons.block, Colors.redAccent),
            _menuItem("Cancelled", Icons.cancel, Colors.red),
            _menuItem("Created", Icons.add_circle_outline, Colors.blueGrey),
            _menuItem("In Transit", Icons.local_shipping, Colors.lightBlue),
            _menuItem("Confirm", Icons.check_circle, Colors.teal),
            _menuItem("Distribution", Icons.apartment, Colors.deepPurple),
            _menuItem("In Warehouse", Icons.warehouse, Colors.brown),
            _menuItem("Pickup", Icons.store_mall_directory, Colors.indigo),
            _menuItem("Retrieve", Icons.assignment_return, Colors.cyan),
            _menuItem("Returned", Icons.keyboard_return, Colors.purple),
            const PopupMenuDivider(),
            _menuItem("Driver Paid", Icons.account_balance_wallet, Colors.tealAccent),
            _menuItem("Customer Paid", Icons.payment, Colors.indigoAccent),
            _menuItem("Driver Not Paid", Icons.warning, Colors.orangeAccent),
            _menuItem("Customer Not Paid", Icons.error, Colors.redAccent),
            const PopupMenuDivider(),
            _menuItem("Edit Shipment", Icons.edit, Colors.black87),
            _menuItem("Print Label", Icons.print, Colors.black87),
            _menuItem("Send Mail", Icons.mail, Colors.black87),
          ],
          onSelected: (value) async {
            if (statusColors.containsKey(value)) {
              setState(() {
                shipments[index]["selectedStatus"] = value;
              });

              // Update Firestore
              try {
                await FirebaseFirestore.instance
                    .collection('shipments')
                    .doc(shipment["id"])
                    .update({'secondAdminValue': value});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error updating Firestore: $e")),
                );
              }
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Action: $value")));
            }
          },
        ),
      ),
    ]);
  }



  PopupMenuItem<String> _menuItem(String text, IconData icon, Color color) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
