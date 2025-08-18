import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_shipment_screen.dart';

class ShipmentsListStyled extends StatefulWidget {
  const ShipmentsListStyled({super.key});

  @override
  State<ShipmentsListStyled> createState() => _ShipmentsListStyledState();
}

class _ShipmentsListStyledState extends State<ShipmentsListStyled> {
  String searchQuery = "";
  String statusFilter = "";
  Set<String> expandedRows = {};

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
            _buildTopControls(),
            const SizedBox(height: 20),
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
                    return const Center(
                        child: Text("No shipments found", style: TextStyle(fontSize: 18)));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final matchesSearch = searchQuery.isEmpty ||
                        (data['receiverName'] ?? "")
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery) ||
                        (data['city'] ?? "").toString().toLowerCase().contains(searchQuery);
                    final matchesStatus = statusFilter.isEmpty ||
                        (data['status'] ?? "").toString().trim().toLowerCase() ==
                            statusFilter.trim().toLowerCase();
                    return matchesSearch && matchesStatus;
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          color: Colors.blue.shade100,
                          child: Row(
                            children: const [
                              Expanded(flex: 2, child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text("City", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 1, child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          ),
                        );
                      }

                      final doc = filteredDocs[index - 1];
                      final data = doc.data() as Map<String, dynamic>;
                      final status = (data['status'] ?? '').toString();
                      final statusNormalized = status.toLowerCase().trim();
                      final isExpanded = expandedRows.contains(doc.id);

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: Text(data['receiverName'] ?? "")),
                                Expanded(flex: 2, child: Text(data['city'] ?? "")),
                                Expanded(flex: 1, child: Text("MAD ${data['price'] ?? ''}")),
                                Expanded(flex: 2, child: _buildStatusChip(status)),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      if (statusNormalized == 'created' ||
                                          statusNormalized == 'pickup' ||
                                          statusNormalized == 'confirmed')
                                        _buildActionsMenu(doc.id, data, statusNormalized),
                                      IconButton(
                                        icon: Icon(
                                          isExpanded ? Icons.expand_less : Icons.expand_more,
                                          color: Colors.blueGrey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isExpanded) {
                                              expandedRows.remove(doc.id);
                                            } else {
                                              expandedRows.add(doc.id);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded)
                            Container(
                              width: double.infinity,
                              color: Colors.blue.shade50,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow("Address", data['address'] ?? 'N/A'),
                                  _buildDetailRow("Phone", data['phone'] ?? 'N/A'),
                                  _buildDetailRow(
                                      "Created At", data['createdAt']?.toDate().toString() ?? 'N/A'),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Barre du haut rendue responsive avec Wrap
  Widget _buildTopControls() {
    return Container(
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
      child: Wrap(
        runSpacing: 8,
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddShipmentScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Create New Order", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: _pickupAllConfirmed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Pickup", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          SizedBox(
            width: 150,
            child: _buildSearchField("Tracking ID"),
          ),
          SizedBox(
            width: 200,
            child: _buildSearchField("Search Tracking", onChanged: (value) {
              setState(() => searchQuery = value.toLowerCase());
            }),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {},
          ),
          DropdownButton<String>(
            value: statusFilter.isEmpty ? null : statusFilter,
            hint: const Text("-- Status --"),
            underline: const SizedBox(),
            items: ["All", "Created", "Pickup", "Confirmed"]
                .map((status) => DropdownMenuItem(value: status == "All" ? "" : status, child: Text(status)))
                .toList(),
            onChanged: (value) => setState(() => statusFilter = value ?? ""),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
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
          ) ?? false;
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