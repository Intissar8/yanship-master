import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Set<String> expandedRows = {};

  // Cache pour les infos drivers
  Map<String, Map<String, String>> driverCache = {};

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
      label: Text(
        _t(status.toLowerCase(), _currentLang),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.15),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
              child: Image.asset(
                'assets/images/logo.png',
                height: 45,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _t("dashboard_driver", _currentLang),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                // ======= ICI on ouvre le profil du driver =======
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(child: const Icon(Icons.person)),
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
                    return Center(
                      child: Text(
                        _t("no_shipments", _currentLang),
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
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

  // ================== Search & Filter Controls ==================
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
  Widget _buildMobileView(List<QueryDocumentSnapshot> filteredDocs) {
    return ListView.builder(
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final doc = filteredDocs[index];
        final data = doc.data() as Map<String, dynamic>;
        final isExpanded = expandedRows.contains(doc.id);
        final driverName = driverCache[data['driverId']]?['name'] ?? "-";

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  title: Text(data['receiverName'] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${_t("city", _currentLang)}: ${data['city'] ?? ""}"),
                      Text("${_t("status", _currentLang)}: ${data['status'] ?? ""}"),
                    ],
                  ),
                  trailing: IconButton(
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
                ),
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.blue.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(_t("sender", _currentLang), driverName),
                        _buildDetailRow(_t("receiver", _currentLang), data['receiverName'] ?? "-"),
                        _buildDetailRow(_t("price", _currentLang), "MAD ${data['price'] ?? ''}"),
                        _buildDetailRow(_t("city", _currentLang), data['city'] ?? "-"),
                        _buildDetailRow(_t("status", _currentLang), data['status'] ?? "-"),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

// ================== WEB VIEW ==================
  Widget _buildWebView(List<QueryDocumentSnapshot> filteredDocs) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 700, maxWidth: 1200),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: Colors.blue.shade100,
                child: Row(
                  children: [
                    SizedBox(width: 200, child: Text(_t("sender", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 200, child: Text(_t("receiver", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 120, child: Text(_t("price", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 150, child: Text(_t("city", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 150, child: Text(_t("status", _currentLang), style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              // Rows
              ...filteredDocs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final isExpanded = expandedRows.contains(doc.id);
                final driverName = driverCache[data['driverId']]?['name'] ?? "-";

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
                          SizedBox(width: 200, child: Text(driverName)),
                          SizedBox(width: 200, child: Text(data['receiverName'] ?? "")),
                          SizedBox(width: 120, child: Text("MAD ${data['price'] ?? ''}")),
                          SizedBox(width: 150, child: Text(data['city'] ?? "-")),
                          SizedBox(
                            width: 150,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildStatusChip(data['status'] ?? ""),
                            ),
                          ),
                          IconButton(
                            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.blueGrey),
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
                    if (isExpanded)
                      Container(
                        width: double.infinity,
                        color: Colors.blue.shade50,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(_t("sender", _currentLang), driverName),
                            _buildDetailRow(_t("receiver", _currentLang), data['receiverName'] ?? "-"),
                            _buildDetailRow(_t("price", _currentLang), "MAD ${data['price'] ?? ''}"),
                            _buildDetailRow(_t("city", _currentLang), data['city'] ?? "-"),
                            _buildDetailRow(_t("status", _currentLang), data['status'] ?? "-"),
                          ],
                        ),
                      ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }}