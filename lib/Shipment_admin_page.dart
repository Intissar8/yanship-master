import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'PrintLabelPage.dart';
import 'add_shipment_screen.dart';
import 'create_shipp_admin.dart';
import 'package:fl_chart/fl_chart.dart';

class ShipmentsTablePage extends StatefulWidget {
  const ShipmentsTablePage({super.key});

  @override
  State<ShipmentsTablePage> createState() => _ShipmentsTablePageState();
}

class _ShipmentsTablePageState extends State<ShipmentsTablePage> {
  List<Map<String, dynamic>> allShipments = [];
  List<Map<String, dynamic>> shipments = [];

  String? selectedStatus;
  String trackingFilter = "";

  final Map<String, Color> statusColors = {
    "Created": Colors.blueGrey,
    "In Transit": Colors.lightBlue,
    "Cancelled": Colors.red,
    "Confirm": Colors.teal,
    "Distribution": Colors.deepPurple,
    "In Warehouse": Colors.brown,
    "No answer": Colors.orange,
    "Picked up": Colors.lightGreen,
    "Pickup": Colors.indigo,
    "Rejected": Colors.redAccent,
    "Reported": Colors.amber,
    "Retrieve": Colors.cyan,
    "Returned": Colors.purple,
    "Delivered": Colors.green,
    "Driver Paid": Colors.tealAccent,
    "Customer Paid": Colors.indigoAccent,
    "Driver Not Paid": Colors.orangeAccent,
    "Customer Not Paid": Colors.redAccent,
  };

  @override
  void initState() {
    super.initState();

  }
  Map<String, int> getShipmentStatusCounts() {
    final Map<String, int> counts = {};
    for (var s in allShipments) {
      final status = s['status'] ?? 'Unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }


  Widget buildStatusHistogramFromData(List<Map<String, dynamic>> shipmentsData) {
    final counts = <String, int>{};
    for (var s in shipmentsData) {
      final status = s['status'] ?? 'Unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    final barGroups = <BarChartGroupData>[];
    int i = 0;
    counts.forEach((status, count) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: statusColors[status] ?? Colors.grey,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      i++;
    });

    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (counts.values.isEmpty
              ? 1
              : counts.values.reduce((a, b) => a > b ? a : b))
              .toDouble() + 1,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= counts.keys.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      counts.keys.elementAt(index),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }



  Future<void> _sendWhatsAppMessage(String shipmentId) async {
    try {
      final shipmentDoc = await FirebaseFirestore.instance
          .collection('shipments')
          .doc(shipmentId)
          .get();
      final shipment = shipmentDoc.data();
      if (shipment == null) return;

      final driverId = shipment['driverId'];
      if (driverId == null || driverId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No driver assigned to this shipment")),
        );
        return;
      }

      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();
      final driver = driverDoc.data();
      if (driver == null || driver['phone'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Driver has no phone number saved")),
        );
        return;
      }

      // --- FIX: format phone number ---
      String phone = driver['phone'].toString().trim();

      // if phone starts with 0, replace with country code (example: Morocco +212)
      if (phone.startsWith("0")) {
        phone = "+212${phone.substring(1)}";
      }

      // make sure it starts with + (international format)
      if (!phone.startsWith("+")) {
        phone = "+$phone";
      }

      final tracking = shipment['trackingNumber'] ?? '';
      final address = shipment['address'] ?? '';
      final city = shipment['city'] ?? '';

      final message =
          "Hello ${driver['firstName'] ?? ''},\n\n"
          "A new shipment has been assigned to you.\n\n"
          " Tracking: $tracking\n"
          " Address: $address, $city\n\n"
          "Please proceed with the delivery.";

      final url =
          "https://wa.me/${phone.replaceAll("+", "")}?text=${Uri.encodeComponent(message)}";

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw "Could not open WhatsApp";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending WhatsApp message: $e")),
      );
    }
  }



  Future<void> _showAssignDriverDialog(String shipmentId) async {
    String? selectedDriverId;

    // Fetch all active drivers
    final driversSnapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .where('status', isEqualTo: 'active')
        .get();

    List<Map<String, dynamic>> drivers = driversSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id": doc.id,
        "name": "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim()
      };
    }).toList();

    if (drivers.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No active drivers found")));
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Driver"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<String>(
              value: selectedDriverId,
              decoration: const InputDecoration(
                labelText: "Select Driver",
                border: OutlineInputBorder(),
              ),
              items: drivers
                  .map((d) => DropdownMenuItem<String>(
                value: d["id"] as String,
                child: Text(d["name"] as String),
              ))
                  .toList(),
              onChanged: (val) => setState(() => selectedDriverId = val),
            );
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                if (selectedDriverId == null) return;

                try {
                  await FirebaseFirestore.instance
                      .collection('shipments')
                      .doc(shipmentId)
                      .update({'driverId': selectedDriverId});

                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Driver assigned successfully")));

                  Navigator.pop(context);

                  // Refresh shipments list

                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error assigning driver: $e")));
                }
              },
              child: const Text("Assign")),
        ],
      ),
    );
  }


  Stream<List<Map<String, dynamic>>> shipmentStream() {
    return FirebaseFirestore.instance
        .collection('shipments')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> tempList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Sender name
        final clientId = data['clientId'] as String?;
        final senderName = clientId != null ? await getClientName(clientId) : "-";

        // Driver name
        final driverId = data['driverId'] as String?;
        final driverName = driverId != null ? await getDriverName(driverId) : "-";

        // Fee
        double fee = 0;
        if (data['packages'] != null && (data['packages'] as List).isNotEmpty) {
          fee = (data['packages'][0]['additionalCharge'] ?? 0).toDouble();
        }

        tempList.add({
          "id": doc.id,
          "sender": senderName,
          "driver": driverName,
          "receiver": data['receiverName']?.toString() ?? "-",
          "city": data['city']?.toString() ?? "-",
          "address": data['address']?.toString() ?? "-",
          "price": data['totalPrice']?.toString() ?? data['price']?.toString() ?? "-",
          "fee": fee.toString(),
          "status": data['deliveryStatus']?.toString() ?? "-",
          "trackingNumber": data['trackingNumber']?.toString() ?? "",
          "statusColor": statusColors[data['deliveryStatus']] ?? Colors.grey,
          "selectedStatus": data['secondAdminValue']?.toString() ?? "",
        });
      }

      return tempList;
    });
  }



  void applyFilters() {
    setState(() {
      shipments = allShipments.where((s) {
        final statusMatch = selectedStatus == null || selectedStatus!.isEmpty
            ? true
            : s['status'] == selectedStatus;
        final trackingMatch = trackingFilter.isEmpty
            ? true
            : s['trackingNumber'].toLowerCase().contains(trackingFilter.toLowerCase());
        return statusMatch && trackingMatch;
      }).toList();
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
      backgroundColor: Colors.grey[100],
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
            // Filters & Add Button Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSearchBox(
                        "Search tracking",
                        icon: Icons.search,
                        onChanged: (val) {
                          trackingFilter = val;
                          applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        hint: "-- Select shipping status --",
                        items: {
                          "All": Icons.list,
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
                        onChanged: (val) {
                          selectedStatus = val == "All" ? null : val;
                          applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        elevation: 3,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ShipmentFormStyledPage()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Shipment", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Histogram Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: shipmentStream(),
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? [];
                    return buildStatusHistogramFromData(data);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Table
            // Table
            Expanded(
              child: Card(
                elevation: 3,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32, // match padding of parent
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: shipmentStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        allShipments = snapshot.data ?? [];
                        shipments = allShipments.where((s) {
                          final statusMatch = selectedStatus == null || selectedStatus!.isEmpty
                              ? true
                              : s['status'] == selectedStatus;
                          final trackingMatch = trackingFilter.isEmpty
                              ? true
                              : s['trackingNumber']
                              .toLowerCase()
                              .contains(trackingFilter.toLowerCase());
                          return statusMatch && trackingMatch;
                        }).toList();

                        return DataTable(
                          headingRowHeight: 50,
                          dataRowHeight: null,
                          headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }


  Widget _buildSearchBox(String hint,
      {IconData? icon, double? width, Function(String)? onChanged}) {
    return SizedBox(
      width: width,
      child: TextField(
        onChanged: onChanged,
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

  Widget _buildDropdown({required String hint, required Map<String, IconData> items, Function(String?)? onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightBlue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
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
          onChanged: onChanged,
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
          itemBuilder: (context) {
            List<PopupMenuEntry<String>> items = [
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
            ];

            // Only show "Assign Driver" if status is "Confirm"
            if (shipment["status"] == "Confirm") {
              items.add(_menuItem("Assign Driver", Icons.drive_eta, Colors.teal));
            }

            return items;
          },
          onSelected: (value) async {
            if (statusColors.containsKey(value)) {
              setState(() {
                shipments[index]["selectedStatus"] = value;
              });

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
            } else if (value == "Assign Driver") {
              _showAssignDriverDialog(shipment["id"]);
            } else if (value == "Edit Shipment") {
              // Navigate to AddShipmentScreen with the shipment ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddShipmentScreen(
                    shipmentId: shipment["id"],
                    currentLang: 'en', // or pass the appropriate language
                  ),
                ),
              );
            }else if (value == "Send Mail") {
              _sendWhatsAppMessage(shipment["id"]);
            } else if (value == "Print Label") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrintLabelPage(shipment: shipment),
                ),
              );

            }else {
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
