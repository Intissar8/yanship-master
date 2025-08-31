import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'PrintLabelPage.dart';
import 'add_shipment_screen.dart';
import 'adminProfileScreen.dart';
import 'create_shipp_admin.dart';
import 'package:fl_chart/fl_chart.dart';

import 'login_screen.dart';

class ShipmentsTablePage extends StatefulWidget {
  const ShipmentsTablePage({super.key});

  @override
  State<ShipmentsTablePage> createState() => _ShipmentsTablePageState();
}

class _ShipmentsTablePageState extends State<ShipmentsTablePage> {
  List<Map<String, dynamic>> allShipments = [];
  List<Map<String, dynamic>> shipments = [];
  int _currentIndex = -1; // 0 = Create Shipment, 1 = Shipment List, 2 = Customers, 3 = Drivers



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

// Normal cell for mobile card
  Widget _buildCardCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> shipment, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Tracking number + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tracking: ${shipment["trackingNumber"] ?? "-"}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildCardCellChip(shipment["status"]),
              ],
            ),
            const SizedBox(height: 8),

            // Sender and Driver
            Row(
              children: [
                Expanded(
                  child: _buildCardInfo("Sender", shipment["sender"]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCardInfo("Driver", shipment["driver"]),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Receiver and City
            Row(
              children: [
                Expanded(
                  child: _buildCardInfo("Receiver", shipment["receiver"]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCardInfo("City", shipment["city"]),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Price and Fee
            Row(
              children: [
                Expanded(
                  child: _buildCardInfo("Price", shipment["price"]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCardInfo("Fee", shipment["fee"]),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Bottom row: Selected Status + Action menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildCardCellChip(shipment["selectedStatus"])),
                _buildCardActionMenu(shipment, index),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Helper to show label + value vertically
  Widget _buildCardInfo(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          value ?? "-",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


// Colored status chip
  Widget _buildCardCellChip(String? status) {
    if (status == null || status.isEmpty) return _buildCardCell("-");
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: (statusColors[status] ?? Colors.grey).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: statusColors[status] ?? Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

// Action menu for mobile card (all web options)
  Widget _buildCardActionMenu(Map<String, dynamic> shipment, int index) {
    return Container(
      width: 120,
      alignment: Alignment.center,
      child: PopupMenuButton<String>(
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
            await FirebaseFirestore.instance
                .collection('shipments')
                .doc(shipment["id"])
                .update({'secondAdminValue': value});
          } else if (value == "Assign Driver") {
            _showAssignDriverDialog(shipment["id"]);
          } else if (value == "Edit Shipment") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddShipmentScreen(
                  shipmentId: shipment["id"],
                  currentLang: 'en',
                ),
              ),
            );
          } else if (value == "Send Mail") {
            _sendWhatsAppMessage(shipment["id"]);
          } else if (value == "Print Label") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PrintLabelPage(shipment: shipment),
              ),
            );
          }
        },
      ),
    );
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

      // --- Format phone number ---
      String phone = driver['phone'].toString().trim();
      if (phone.startsWith("0")) {
        phone = "+212${phone.substring(1)}"; // example Morocco
      }
      if (!phone.startsWith("+")) {
        phone = "+$phone";
      }

      final tracking = shipment['trackingNumber'] ?? '';
      final address = shipment['address'] ?? '';
      final city = shipment['city'] ?? '';

      final message =
          "Hello ${driver['firstName'] ?? ''},\n\n"
          "A new shipment has been assigned to you.\n\n"
          "Tracking: $tracking\n"
          "Address: $address, $city\n\n"
          "Please proceed with the delivery.";

      // --- Prefer native WhatsApp scheme on mobile ---
      final whatsappUrl = Uri.parse(
        "whatsapp://send?phone=${phone.replaceAll("+", "")}&text=${Uri.encodeComponent(message)}",
      );

      // fallback web URL
      final webUrl = Uri.parse(
        "https://wa.me/${phone.replaceAll("+", "")}?text=${Uri.encodeComponent(message)}",
      );

      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
          throw "Could not open WhatsApp";
        }
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
  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 16,
      title: Row(
        children: [
          // Logo
          Image.asset('assets/images/logo.png', height: 40),

          if (!isMobile) ...[
            const SizedBox(width: 24),
            // Shipments Dropdown
            PopupMenuButton<String>(
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.grey[800], size: 22),
                  const SizedBox(width: 6),
                  Text('Shipments',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500)),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[800], size: 22),
                ],
              ),
              onSelected: (value) {
                if (value == 'Create Shipment') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ShipmentFormStyledPage()));
                } else if (value == 'Shipment List') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ShipmentsTablePage()));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'Create Shipment',
                    child: Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Create Shipment')])),
                const PopupMenuItem(
                    value: 'Shipment List',
                    child: Row(children: [Icon(Icons.list), SizedBox(width: 8), Text('Shipment List')])),
              ],
            ),
            const SizedBox(width: 24),
            // Users Dropdown
            PopupMenuButton<String>(
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[800], size: 22),
                  const SizedBox(width: 6),
                  Text('Users',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500)),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[800], size: 22),
                ],
              ),
              onSelected: (value) {
                if (value == 'Customer List') {
                  // Navigate to customer list page
                } else if (value == 'Driver List') {
                  // Navigate to driver list page
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                    value: 'Customer List',
                    child: Row(children: [Icon(Icons.people), SizedBox(width: 8), Text('Customer List')])),
                const PopupMenuItem(
                    value: 'Driver List',
                    child: Row(children: [Icon(Icons.drive_eta), SizedBox(width: 8), Text('Driver List')])),
              ],
            ),
          ],

          // Spacer to push language + profile to the far right
          const Spacer(),

          // Language Dropdown
          DropdownButton<String>(
            value: 'English',
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.grey),
            onChanged: (value) {},
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English')),
              DropdownMenuItem(value: 'French', child: Text('French')),
              DropdownMenuItem(value: 'Arabic', child: Text('Arabic')),
            ],
          ),
          const SizedBox(width: 12),

          // Profile Circle
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const AdminProfileScreen()));
              } else if (value == 'logout') {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person, color: Colors.blue), SizedBox(width: 8), Text('View Profile')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Logout')])),
            ],
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(isMobile),

      body: _buildBody(isMobile),

      // Bottom Navigation Bar only on mobile
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex < 0 ? 0 : _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ShipmentFormStyledPage()));
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ShipmentsTablePage()));
              break;
            case 2:
            // Customers
              break;
            case 3:
            // Drivers
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create Shipment'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Shipment List'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(icon: Icon(Icons.drive_eta), label: 'Drivers'),
        ],
      )
          : null,

    );
  }

  Widget _buildBody(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filters
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSearchBox("Search tracking",
                      icon: Icons.search, onChanged: (val) {
                        trackingFilter = val;
                        applyFilters();
                      }),
                  const SizedBox(height: 16),
                  _buildDropdown(
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
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ShipmentFormStyledPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Shipment",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
                  : Row(
                children: [
                  Expanded(
                    child: _buildSearchBox("Search tracking",
                        icon: Icons.search, onChanged: (val) {
                          trackingFilter = val;
                          applyFilters();
                        }),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ShipmentFormStyledPage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Shipment",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Histogram
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

          // Table (web) or Cards (mobile)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: shipmentStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data ?? [];
                allShipments = data;

                shipments = allShipments.where((s) {
                  final statusMatch =
                  selectedStatus == null || selectedStatus!.isEmpty
                      ? true
                      : s['status'] == selectedStatus;
                  final trackingMatch = trackingFilter.isEmpty
                      ? true
                      : s['trackingNumber']
                      .toLowerCase()
                      .contains(trackingFilter.toLowerCase());
                  return statusMatch && trackingMatch;
                }).toList();

                if (isMobile) {
                  return ListView.builder(
                    itemCount: shipments.length,
                    itemBuilder: (context, index) {
                      final shipment = shipments[index];

                      return _buildShipmentCard(shipments[index], index);
                    },
                  );

                }
                else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      color: Colors.white, // ✅ force table background white
                      width: MediaQuery.of(context).size.width,
                      child: DataTable(
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
                      ),
                    ),
                  );

                }

              },
            ),
          ),
        ],
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

    final bool isEven = index % 2 == 0;
    final Color rowColor = isEven ? Colors.white : Colors.white54; // Alternating colors

    return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            return rowColor; // Row background color
          },
        ),
        cells: [
          DataCell(Text(shipment["sender"] ?? "-")),
          DataCell(Text(shipment["driver"] ?? "-")),
          DataCell(Text(shipment["receiver"] ?? "-")),
          DataCell(Text(shipment["city"] ?? "-")),
          DataCell(Text(shipment["price"]?.toString() ?? "-")),
          DataCell(Text(shipment["fee"]?.toString() ?? "-")),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (statusColors[shipment["status"]] ?? Colors.grey).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12), // Rounded edges
              ),
              child: Text(
                shipment["status"] ?? "-",
                style: TextStyle(
                  color: statusColors[shipment["status"]] ?? Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          DataCell(
            shipment["selectedStatus"] == null || shipment["selectedStatus"] == ""
                ? const SizedBox()
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (statusColors[shipment["selectedStatus"]] ?? Colors.grey)
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12), // Rounded edges
              ),
              child: Text(
                shipment["selectedStatus"],
                style: TextStyle(
                  color: statusColors[shipment["selectedStatus"]] ?? Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          DataCell(
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              icon: const Icon(Icons.more_vert, color: Colors.black),
              itemBuilder: (context) {
                // same menu items as before
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
