import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_shipment_screen.dart';
import 'ShipmentDetailsScreen.dart';

class ShipmentsListStyled extends StatefulWidget {
  const ShipmentsListStyled({super.key});

  @override
  State<ShipmentsListStyled> createState() => _ShipmentsListStyledState();
}

class _ShipmentsListStyledState extends State<ShipmentsListStyled> {
  String searchQuery = "";
  String statusFilter = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text("Dashboard Customer"),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Top controls row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddShipmentScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Create New Order",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _pickupAllConfirmed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Pickup", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const Spacer(),
                  SizedBox(width: 150, child: _buildSearchField("Tracking ID")),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 200,
                    child: _buildSearchField("Search Tracking", onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    }),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: statusFilter.isEmpty ? null : statusFilter,
                    hint: const Text("-- Status --"),
                    underline: const SizedBox(),
                    items: ["All", "Created", "Pickup", "Confirmed"]
                        .map((status) => DropdownMenuItem(
                      value: status == "All" ? "" : status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => statusFilter = value ?? ""),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Centered and bigger table
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('shipments')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No shipments found", style: TextStyle(fontSize: 18)));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final matchesSearch = searchQuery.isEmpty ||
                        (data['receiverName'] ?? "").toString().toLowerCase().contains(searchQuery) ||
                        (data['city'] ?? "").toString().toLowerCase().contains(searchQuery);
                    final matchesStatus = statusFilter.isEmpty ||
                        (data['status'] ?? "").toString().trim().toLowerCase() ==
                            statusFilter.trim().toLowerCase();
                    return matchesSearch && matchesStatus;
                  }).toList();

                  return Center( // centers the table
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1400), // bigger width for the table
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 60,
                          dataRowHeight: 56,
                          columnSpacing: 50,
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          dataTextStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
                          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.blue.withOpacity(0.08);
                              }
                              return null;
                            },
                          ),
                          columns: const [
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("City")),
                            DataColumn(label: Text("Price")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: filteredDocs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final status = (data['status'] ?? '').toString();
                            final statusNormalized = status.toLowerCase().trim();

                            return DataRow(
                              cells: [
                                DataCell(Text(data['receiverName'] ?? "")),
                                DataCell(Text(data['city'] ?? "")),
                                DataCell(Text("MAD ${data['price'] ?? ''}")),
                                DataCell(_buildStatusChip(status)),
                                DataCell(Row(
                                  children: [
                                    if (statusNormalized == 'created' ||
                                        statusNormalized == 'pickup' ||
                                        statusNormalized == 'confirmed')
                                      _buildActionsMenu(doc.id, data, statusNormalized),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ShipmentDetailsScreen(
                                              shipmentId: doc.id,
                                              shipmentData: data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(String hint, {ValueChanged<String>? onChanged}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      onChanged: onChanged,
    );
  }

  PopupMenuButton<String> _buildActionsMenu(String id, Map<String, dynamic> data, String status) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (selected) async {
        if (selected == 'confirm') {
          await FirebaseFirestore.instance.collection('shipments').doc(id).update({'status': 'Confirmed'});
        } else if (selected == 'edit') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddShipmentScreen(shipmentId: id)));
        } else if (selected == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Confirm delete'),
              content: const Text('Are you sure you want to delete this shipment?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
              ],
            ),
          ) ??
              false;
          if (confirm) {
            await FirebaseFirestore.instance.collection('shipments').doc(id).delete();
          }
        } else if (selected == 'print') {
          // TODO: print logic
        }
      },
      itemBuilder: (context) {
        if (status == 'pickup' || status == 'confirmed') {
          return [
            const PopupMenuItem(
              value: 'print',
              child: Row(children: [Icon(Icons.print), SizedBox(width: 8), Text('Print Label')]),
            ),
          ];
        } else {
          return [
            const PopupMenuItem(
              value: 'confirm',
              child: Row(children: [Icon(Icons.check_circle, color: Colors.blue), SizedBox(width: 8), Text('Confirm Shipment')]),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [Icon(Icons.edit, color: Colors.black54), SizedBox(width: 8), Text('Edit Shipment')]),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 8), Text('Delete Shipment')]),
            ),
            const PopupMenuItem(
              value: 'print',
              child: Row(children: [Icon(Icons.print), SizedBox(width: 8), Text('Print Label')]),
            ),
          ];
        }
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "created":
        color = Colors.blue;
        break;
      case "pickup":
        color = Colors.lightBlue;
        break;
      case "confirmed":
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      backgroundColor: color.withOpacity(0.15),
    );
  }

  Future<void> _pickupAllConfirmed() async {
    try {
      final confirmedShipments = await FirebaseFirestore.instance
          .collection('shipments')
          .where('status', isEqualTo: 'Confirmed')
          .get();
      for (var doc in confirmedShipments.docs) {
        await doc.reference.update({'status': 'Pickup'});
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${confirmedShipments.docs.length} shipment(s) moved to Pickup."),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error updating shipments: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
