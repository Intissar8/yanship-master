import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'acceuil.dart';
import 'DriverProfileScreen.dart';

// ================== Traduction ==================
String _t(String key, String lang) {
  switch (lang) {
    case 'fr':
      return {
        "dashboard_driver": "Tableau de bord chauffeur",
        "my_shipments": "Mes expéditions",
        "view_profile": "Voir le profil",
        "logout": "Se déconnecter",
        "no_shipments": "Aucune expédition assignée",
        "sender": "Expéditeur",
        "receiver": "Destinataire",
        "price": "Prix",
        "city": "Ville",
        "status": "Statut",
        "actions": "Actions",
        "search": "Rechercher",
        "all": "Tous",
        "created": "Créée",
        "pickup": "En collecte",
        "confirmed": "Confirmée",
        "update_status": "Changer le statut",
      }[key] ?? key;
    case 'ar':
      return {
        "dashboard_driver": "لوحة تحكم السائق",
        "my_shipments": "شحناتي",
        "view_profile": "عرض الملف الشخصي",
        "logout": "تسجيل الخروج",
        "no_shipments": "لا توجد شحنات مخصصة لك",
        "sender": "المرسل",
        "receiver": "المستلم",
        "price": "السعر",
        "city": "المدينة",
        "status": "الحالة",
        "actions": "إجراءات",
        "search": "بحث",
        "all": "الكل",
        "created": "تم الإنشاء",
        "pickup": "في الاستلام",
        "confirmed": "تم التأكيد",
        "update_status": "تغيير الحالة",
      }[key] ?? key;
    default:
      return {
        "dashboard_driver": "Driver Dashboard",
        "my_shipments": "My Shipments",
        "view_profile": "View Profile",
        "logout": "Logout",
        "no_shipments": "No shipments assigned to you.",
        "sender": "Sender",
        "receiver": "Receiver",
        "price": "Price",
        "city": "City",
        "status": "Status",
        "actions": "Actions",
        "search": "Search",
        "all": "All",
        "created": "Created",
        "pickup": "Pickup",
        "confirmed": "Confirmed",
        "update_status": "Update Status",
      }[key] ?? key;
  }
}

// ================== DriverShipmentsPage ==================
class DriverShipmentsPage extends StatefulWidget {
  const DriverShipmentsPage({super.key});

  @override
  State<DriverShipmentsPage> createState() => _DriverShipmentsPageState();
}

class _DriverShipmentsPageState extends State<DriverShipmentsPage> {
  String _currentLang = 'en';
  String searchQuery = "";
  String? selectedStatus;
  Map<String, Map<String, String>> driverCache = {};
  Map<String, bool> _expandedShipments = {}; // pour mobile

  @override
  void initState() {
    super.initState();
    _preloadDrivers();
  }

  Future<void> _preloadDrivers() async {
    final snapshot = await FirebaseFirestore.instance.collection('drivers').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
      driverCache[doc.id] = {'name': name, 'avatarUrl': data['avatarUrl'] ?? ''};
    }
    setState(() {});
  }

  // ================== Format Timestamp ==================
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-';
    try {
      final date = timestamp is DateTime
          ? timestamp
          : (timestamp is Timestamp ? timestamp.toDate() : DateTime.parse(timestamp.toString()));
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return '-';
    }
  }

  // ================== Popup Web ==================
  void _showShipmentDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Shipment Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow("Receiver", data['receiverName']),
                _buildDetailRow("Price", "MAD ${data['price'] ?? '-'}"),
                _buildDetailRow("City", data['city']),
                _buildDetailRow("Status", data['deliveryStatus'] ?? data['status']),
                _buildDetailRow("Address", data['address']),
                _buildDetailRow("Created At", _formatTimestamp(data['createdAt'])),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================== Detail Row Widget ==================
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? '-', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ================== Update Status ==================
  Future<void> _updateStatus(String shipmentId, String newStatus) async {
    await FirebaseFirestore.instance.collection('shipments').doc(shipmentId).update({
      "deliveryStatus": newStatus,
    });
  }

  void _showStatusDialog(String shipmentId) {
    final statuses = ["Picked up", "No Answer", "Reported", "Rejected", "Cancelled", "Delivered"];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_t("update_status", _currentLang)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses
                .map(
                  (status) => ListTile(
                title: Text(status),
                onTap: () async {
                  Navigator.pop(context);
                  await _updateStatus(shipmentId, status);
                },
              ),
            )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    IconData icon;
    Color color;

    switch (status.toLowerCase()) {
      case "picked up":
        icon = Icons.inventory_2;
        color = Colors.orange;
        break;
      case "no answer":
        icon = Icons.phone_missed;
        color = Colors.redAccent;
        break;
      case "delivered":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "canceled":
        icon = Icons.cancel;
        color = Colors.grey;
        break;
      case "in progress":
        icon = Icons.local_shipping;
        color = Colors.blue;
        break;
      case "pending":
        icon = Icons.hourglass_empty;
        color = Colors.amber;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(status, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: const Color(0xFFF5F4FA),
        titleSpacing: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Image.asset('assets/images/logo.png', height: 45),
            ),
            const SizedBox(width: 12),
            Text(
              _t("dashboard_driver", _currentLang),
              style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: _currentLang,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.black87),
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            onChanged: (value) {
              if (value != null) setState(() => _currentLang = value);
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text("EN")),
              DropdownMenuItem(value: 'fr', child: Text("FR")),
              DropdownMenuItem(value: 'ar', child: Text("AR")),
            ],
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverProfileScreen(
                      currentLang: _currentLang,
                      driverId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                );
              } else if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(_t("view_profile", _currentLang)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(_t("logout", _currentLang)),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildTopControls(isMobile),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('shipments')
                    .where('driverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text(_t("no_shipments", _currentLang), style: const TextStyle(fontSize: 18)));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final matchesSearch = searchQuery.isEmpty ||
                        (data['receiverName'] ?? "").toString().toLowerCase().contains(searchQuery) ||
                        (data['city'] ?? "").toString().toLowerCase().contains(searchQuery);
                    final matchesStatus = selectedStatus == null ||
                        selectedStatus == "All" ||
                        (data['status'] ?? "").toString().toLowerCase() == selectedStatus!.toLowerCase();
                    return matchesSearch && matchesStatus;
                  }).toList();

                  return isMobile
                      ? _buildMobileView(filteredDocs)
                      : _buildWebView(filteredDocs);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== TOP CONTROLS ==================
  Widget _buildTopControls(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                hintText: _t("search", _currentLang),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: selectedStatus ?? "All",
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.filter_list, color: Colors.blue),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value == "All" ? null : value;
                });
              },
              items: [
                DropdownMenuItem(value: "All", child: Text(_t("all", _currentLang))),
                DropdownMenuItem(value: "Created", child: Text(_t("created", _currentLang))),
                DropdownMenuItem(value: "Pickup", child: Text(_t("pickup", _currentLang))),
                DropdownMenuItem(value: "Confirmed", child: Text(_t("confirmed", _currentLang))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== MOBILE VIEW ==================
  // ================== MOBILE VIEW ==================
  Widget _buildMobileView(List<QueryDocumentSnapshot> filteredDocs) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 4),
        children: filteredDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final deliveryStatus = data['deliveryStatus'] ?? data['status'] ?? "-";
          final shipmentId = doc.id;
          final city = data['city'] ?? "-";

          return ExpansionPanelRadio(
            value: shipmentId,
            headerBuilder: (context, isExpanded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // <-- centré verticalement
                  children: [
                    // Colonne des infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Receiver: ${data['receiverName'] ?? '-'}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("City: $city", style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text("Status: $deliveryStatus",
                              style: const TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),
                    // Icône stylo alignée verticalement au centre
                    if (deliveryStatus.toLowerCase() != "delivered")
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () => _showStatusDialog(shipmentId),
                        ),
                      ),
                  ],
                ),
              );
            },

            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Receiver", data['receiverName']),
                  _buildDetailRow("Price", "MAD ${data['price'] ?? '-'}"),
                  _buildDetailRow("City", data['city']),
                  _buildDetailRow("Status", deliveryStatus),
                  _buildDetailRow("Address", data['address']),
                  _buildDetailRow("Created At", _formatTimestamp(data['createdAt'])),

                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================== WEB VIEW ==================
  Widget _buildWebView(List<QueryDocumentSnapshot> filteredDocs) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 900, maxWidth: 1500),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.blue.shade100,
                child: Row(
                  children: [
                    SizedBox(width: 250, child: Text(_t("sender", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 250, child: Text(_t("receiver", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 150, child: Text(_t("price", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 200, child: Text(_t("city", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 180, child: Text(_t("status", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 150, child: Text(_t("actions", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Rows
              ...filteredDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final driverName = driverCache[data['driverId']]?['name'] ?? "-";
                final deliveryStatus = data['deliveryStatus'] ?? data['status'] ?? "-";

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 250, child: Text(driverName)),
                      SizedBox(width: 250, child: Text(data['receiverName'] ?? "")),
                      SizedBox(width: 150, child: Text("MAD ${data['price'] ?? ''}")),
                      SizedBox(width: 200, child: Text(data['city'] ?? "-")),
                      SizedBox(
                        width: 180,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _buildStatusChip(deliveryStatus),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Row(
                          children: [
                            if (deliveryStatus.toLowerCase() != "delivered")
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                onPressed: () => _showStatusDialog(doc.id),
                              ),
                            IconButton(
                              icon: const Icon(Icons.info, color: Colors.blue),
                              onPressed: () => _showShipmentDetails(data),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}