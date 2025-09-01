import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomerProfileScreen.dart';
import 'PrintLabelPage.dart';
import 'add_shipment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'acceuil.dart';
import 'dart:typed_data';
import 'dart:convert';


String _t(String key, String lang) {
  switch (lang) {
    case 'fr':
      return {
        "dashboard_customer": "Tableau de bord client",
        "view_profile": "Voir le profil",
        "logout": "Se déconnecter",
        "no_shipments": "Aucune expédition trouvée",
        "city": "Ville",
        "status": "Statut",
        "address": "Adresse",
        "phone": "Téléphone",
        "price": "Prix",
        "name": "Nom",
        "actions": "Actions",
        "created_at": "Créé le",
        "create_order": "Créer une commande",
        "pickup": "Ramassage",
        "profile": "Profil",
        "tracking_id": "ID de suivi",
        "search_tracking": "Rechercher un suivi",
        "all": "Tous",
        "created": "Créé",
        "confirmed": "Confirmé",
        "confirm_shipment": "Confirmer l'expédition",
        "edit_shipment": "Modifier l'expédition",
        "delete_shipment": "Supprimer l'expédition",
        "print_label": "Imprimer l'étiquette",
      }[key] ?? key;

    case 'ar':
      return {
        "dashboard_customer": "لوحة تحكم العميل",
        "view_profile": "عرض الملف الشخصي",
        "logout": "تسجيل الخروج",
        "no_shipments": "لا توجد شحنات",
        "city": "المدينة",
        "status": "الحالة",
        "address": "العنوان",
        "phone": "الهاتف",
        "price": "السعر",
        "name": "الاسم",
        "actions": "إجراءات",
        "created_at": "تاريخ الإنشاء",
        "create_order": "إنشاء طلب جديد",
        "pickup": "استلام",
        "profile": "الملف الشخصي",
        "tracking_id": "رقم التتبع",
        "search_tracking": "بحث التتبع",
        "all": "الكل",
        "created": "تم الإنشاء",
        "confirmed": "مؤكد",
        "confirm_shipment": "تأكيد الشحنة",
        "edit_shipment": "تعديل الشحنة",
        "delete_shipment": "حذف الشحنة",
        "print_label": "طباعة الملصق",
      }[key] ?? key;

    default: // English
      return {
        "dashboard_customer": "Dashboard Customer",
        "view_profile": "View Profile",
        "logout": "Logout",
        "no_shipments": "No shipments found",
        "city": "City",
        "status": "Status",
        "address": "Address",
        "phone": "Phone",
        "price": "Price",
        "name": "Name",
        "actions": "Actions",
        "created_at": "Created At",
        "create_order": "Create New Order",
        "pickup": "Pickup",
        "profile": "Profile",
        "tracking_id": "Tracking ID",
        "search_tracking": "Search Tracking",
        "all": "All",
        "created": "Created",
        "confirmed": "Confirmed",
        "confirm_shipment": "Confirm Shipment",
        "edit_shipment": "Edit Shipment",
        "delete_shipment": "Delete Shipment",
        "print_label": "Print Label",
      }[key] ?? key;
  }
}


class ShipmentsListStyled extends StatefulWidget {
  const ShipmentsListStyled({super.key});


  @override
  State<ShipmentsListStyled> createState() => _ShipmentsListStyledState();
}

class _ShipmentsListStyledState extends State<ShipmentsListStyled> {
  String searchQuery = "";
  String statusFilter = "";
  Set<String> expandedRows = {};
  String _currentLang = 'en'; // default language



  Widget _buildShipmentStats(List<QueryDocumentSnapshot> shipments) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    int total = shipments.length;
    int delivered = shipments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['deliveryStatus'] ?? '').toString().toLowerCase() == "confirm";
    }).length;

    int returned = shipments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['deliveryStatus'] ?? '').toString().toLowerCase() == "returned";
    }).length;

    int rejected = shipments.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['deliveryStatus'] ?? '').toString().toLowerCase() == "rejected";
    }).length;

    final stats = {
      "Total": total,
      "Delivered": delivered,
      "Returned": returned,
      "Rejected": rejected,
    };

    final colors = {
      "Total": Colors.blueGrey,
      "Delivered": Colors.green,
      "Returned": Colors.purple,
      "Rejected": Colors.redAccent,
    };

    final icons = {
      "Total": Icons.inventory_2,
      "Delivered": Icons.check_circle,
      "Returned": Icons.undo,
      "Rejected": Icons.cancel,
    };

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // KPI row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.entries.map((e) {
                return Column(
                  children: [
                    Icon(icons[e.key], color: colors[e.key], size: isMobile ? 16 : 20),
                    const SizedBox(height: 2),
                    Text(
                      "${e.value}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 11 : 14,
                      ),
                    ),
                    Text(
                      e.key,
                      style: TextStyle(
                        fontSize: isMobile ? 9 : 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Bar chart
            SizedBox(
              height: isMobile ? 100 : 140, // ✅ adjust height for mobile
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: stats.entries.map((entry) {
                    return BarChartGroupData(
                      x: stats.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: colors[entry.key] ?? Colors.blueGrey,
                          width: isMobile ? 16 : 22, // narrower bars for mobile
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: isMobile ? 20 : 30,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: isMobile ? 10 : 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final labels = stats.keys.toList();
                          if (value.toInt() < 0 || value.toInt() >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            labels[value.toInt()],
                            style: TextStyle(fontSize: isMobile ? 10 : 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        toolbarHeight: isMobile ? 56 : 72, // ✅ smaller height on mobile
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Image.asset(
              "assets/images/logo.png",
              height: 36,
            ),
            if (!isMobile) ...[
              const SizedBox(width: 12),
              Text(
                _t("dashboard_customer", _currentLang),
                style: TextStyle(
                  color: Colors.black54, // ✅ stronger color
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: _currentLang,
            dropdownColor: Colors.blue.shade800,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.black45, fontSize: 16),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentLang = value;
                });
              }
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('EN')),
              DropdownMenuItem(value: 'fr', child: Text('FR')),
              DropdownMenuItem(value: 'ar', child: Text('AR')),
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
                    builder: (_) => CustomerProfileScreen(currentLang: _currentLang),
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
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('clients')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  );
                }
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                Uint8List? avatarBytes;
                if (data != null &&
                    data['avatarUrl'] != null &&
                    data['avatarUrl'].toString().isNotEmpty) {
                  try {
                    avatarBytes = base64Decode(data['avatarUrl']);
                  } catch (_) {}
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                    avatarBytes != null ? MemoryImage(avatarBytes) : null,
                    child: avatarBytes == null
                        ? Icon(Icons.person, color: Colors.blue.shade800)
                        : null,
                  ),
                );
              },
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
                    .where('clientId', isEqualTo: user!.uid)   // 🔑 on filtre
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No shipments found",
                            style: TextStyle(fontSize: 18)));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final matchesSearch = searchQuery.isEmpty ||
                        (data['receiverName'] ?? "")
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery) ||
                        (data['city'] ?? "")
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery);
                    final matchesStatus = statusFilter.isEmpty ||
                        (data['status'] ?? "").toString().trim().toLowerCase() ==
                            statusFilter.trim().toLowerCase();
                    return matchesSearch && matchesStatus;
                  }).toList();

                  final allDocs = snapshot.data!.docs; // all shipments for the user

                  return Column(
                    children: [
                      ExpansionTile(
                        initiallyExpanded: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        title: const Text(
                          "Shipment Statistics",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54, // ✅ make header white
                          ),
                        ),
                        backgroundColor: Colors.blue.shade50, // optional: give the header a colored background
                        collapsedBackgroundColor: Colors.white,
                        children: [
                          _buildShipmentStats(allDocs), // your existing KPI + chart card
                        ],
                      ),
                      // ✅ histogram on top
                      const SizedBox(height: 20),
                      Expanded(
                        child: isMobile
                            ? _buildMobileView(filteredDocs)
                            : _buildWebView(filteredDocs),
                      ),
                    ],
                  );

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MOBILE VERSION
  Widget _buildMobileView(List<QueryDocumentSnapshot> filteredDocs) {
    return ListView.builder(
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final doc = filteredDocs[index];
        final data = doc.data() as Map<String, dynamic>;
        final status = (data['status'] ?? '').toString();
        final statusNormalized = status.toLowerCase().trim();
        final isExpanded = expandedRows.contains(doc.id);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  title: Text(data['receiverName'] ?? ""),
                  subtitle: Text("City: ${data['city'] ?? ""}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusChip(status),
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
                      if (statusNormalized == 'created' ||
                          statusNormalized == 'pickup' ||
                          statusNormalized == 'confirmed')
                        _buildActionsMenu(doc.id, data, statusNormalized),
                    ],
                  ),
                ),
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: Colors.blue.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(_t("address", _currentLang), data['address'] ?? 'N/A'),
                        _buildDetailRow(_t("phone", _currentLang), data['phone'] ?? 'N/A'),
                        _buildDetailRow(_t("price", _currentLang), "MAD ${data['price'] ?? ''}"),
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
  void _showDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent, // make the background transparent for better shadow
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400), // smaller width
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t("shipment_details", _currentLang),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.black87,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(c),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(Icons.close, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details
                _buildDetailRowModern(_t("address", _currentLang), data['address'] ?? 'N/A'),
                _buildDetailRowModern(_t("phone", _currentLang), data['phone'] ?? 'N/A'),
                _buildDetailRowModern(
                  _t("created_at", _currentLang),
                  data['createdAt'] != null
                      ? (data['createdAt'] is Timestamp
                      ? (data['createdAt'] as Timestamp).toDate().toString()
                      : data['createdAt'].toString())
                      : 'N/A',
                ),
                _buildDetailRowModern(_t("status", _currentLang), data['status'] ?? 'N/A'),
                _buildDetailRowModern(_t("price", _currentLang), "MAD ${data['price'] ?? ''}"),

                const SizedBox(height: 20),

                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(c),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Modern detail row
  Widget _buildDetailRowModern(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }




  /// WEB VERSION
  Widget _buildWebView(List<QueryDocumentSnapshot> filteredDocs) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: screenWidth, // make table take full width
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
              headingTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
                fontSize: 14,
              ),
              dataTextStyle: const TextStyle(fontSize: 13),
              dataRowHeight: 60,
              horizontalMargin: 12,
              columnSpacing: 24,
              dividerThickness: 1,
              columns: [
                DataColumn(label: Text(_t("name", _currentLang))),
                DataColumn(label: Text(_t("city", _currentLang))),
                DataColumn(label: Text(_t("price", _currentLang))),
                DataColumn(label: Text(_t("status", _currentLang))),
                DataColumn(label: Text(_t("actions", _currentLang))),
              ],
              rows: filteredDocs.asMap().entries.map((entry) {
                final index = entry.key;
                final doc = entry.value;
                final data = doc.data() as Map<String, dynamic>;
                final status = (data['status'] ?? '').toString();
                final statusNormalized = status.toLowerCase().trim();

                final rowColor = index % 2 == 0
                    ? MaterialStateProperty.all(Colors.grey.shade50)
                    : MaterialStateProperty.all(Colors.grey.shade100);

                return DataRow(
                  color: rowColor,
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
                          icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                          onPressed: () {
                            _showDetailsDialog(data);
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
      ),
    );
  }





  /// Top controls with new Profile button
  Widget _buildTopControls(bool isMobile) {
    return Container(
      width: double.infinity,
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
      child: isMobile
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First row: Create Order + Pickup
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddShipmentScreen(currentLang: _currentLang),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    _t("create_order", _currentLang),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _pickupAllConfirmed,
                  child: Text(
                    _t("pickup", _currentLang),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Second row: Tracking ID + Search Tracking
          Row(
            children: [
              Expanded(
                child: _buildSearchField(_t("tracking_id", _currentLang)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSearchField(
                  _t("search_tracking", _currentLang),
                  onChanged: (value) =>
                      setState(() => searchQuery = value.toLowerCase()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Third row: Status Dropdown
          DropdownButtonFormField<String>(
            value: statusFilter.isEmpty ? null : statusFilter,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            hint: Text("-- ${_t("status", _currentLang)} --"),
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: "",
                child: Row(
                  children: [
                    const Icon(Icons.list, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(_t("all", _currentLang)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: "Created",
                child: Row(
                  children: [
                    const Icon(Icons.create, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(_t("created", _currentLang)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: "Pickup",
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping,
                        size: 18, color: Colors.black),
                    const SizedBox(width: 6),
                    Text(_t("pickup", _currentLang)),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: "Confirmed",
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 18, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(_t("confirmed", _currentLang)),
                  ],
                ),
              ),
            ],
            onChanged: (value) => setState(() => statusFilter = value ?? ""),
          ),
        ],
      )
          : Row(
        children: [
          // Create Order Button (green)
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddShipmentScreen(currentLang: _currentLang),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                _t("create_order", _currentLang),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Pickup Button (black)
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: _pickupAllConfirmed,
              child: Text(
                _t("pickup", _currentLang),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Tracking ID search
          Expanded(
            flex: 2,
            child: _buildSearchField(_t("tracking_id", _currentLang)),
          ),
          const SizedBox(width: 8),

          // Search Tracking
          Expanded(
            flex: 2,
            child: _buildSearchField(_t("search_tracking", _currentLang),
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                }),
          ),
          const SizedBox(width: 8),

          // Status Dropdown
          Expanded(
            flex: 1,
            child: DropdownButton<String>(
              value: statusFilter.isEmpty ? null : statusFilter,
              hint: Text("-- ${_t("status", _currentLang)} --"),
              isExpanded: true,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: "",
                  child: Row(
                    children: [
                      const Icon(Icons.list, size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(_t("all", _currentLang)),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "Created",
                  child: Row(
                    children: [
                      const Icon(Icons.create, size: 18, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(_t("created", _currentLang)),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "Pickup",
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping,
                          size: 18, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(_t("pickup", _currentLang)),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "Confirmed",
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 18, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(_t("confirmed", _currentLang)),
                    ],
                  ),
                ),
              ],
              onChanged: (value) =>
                  setState(() => statusFilter = value ?? ""),
            ),
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
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      onChanged: onChanged,
    );
  }

  PopupMenuButton<String> _buildActionsMenu(
      String id, Map<String, dynamic> data, String status) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (selected) async {
        if (selected == 'confirm') {
          await FirebaseFirestore.instance
              .collection('shipments')
              .doc(id)
              .update({'status': 'Confirmed'});
        } else if (selected == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddShipmentScreen(
                shipmentId: id,
                currentLang: _currentLang,
              ),
            ),);
        } else if (selected == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Confirm delete'),
              content:
              const Text('Are you sure you want to delete this shipment?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Delete')),
              ],
            ),
          ) ??
              false;
          if (confirm) {
            await FirebaseFirestore.instance
                .collection('shipments')
                .doc(id)
                .delete();
          }
        } else if (selected == 'print') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrintLabelPage(shipment: data),
            ),
          );
        }
      },
      itemBuilder: (context) {
        if (status == 'pickup' || status == 'confirmed') {
          return [
            const PopupMenuItem(
              value: 'print',
              child: Row(children: [
                Icon(Icons.print),
                SizedBox(width: 8),
                Text('Print Label')
              ]),
            ),
          ];
        } else {
          return [
            PopupMenuItem(
              value: 'confirm',
              child: Row(children: [
                Icon(Icons.check_circle, color: Colors.blue),
                SizedBox(width: 8),
                Text(_t("confirm_shipment", _currentLang))
              ]),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit, color: Colors.black54),
                SizedBox(width: 8),
                Text(_t("edit_shipment", _currentLang))
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.cancel, color: Colors.red),
                SizedBox(width: 8),
                Text(_t("delete_shipment", _currentLang))
              ]),
            ),
            PopupMenuItem(
              value: 'print',
              child: Row(children: [
                Icon(Icons.print),
                SizedBox(width: 8),
                Text(_t("print_label", _currentLang))
              ]),
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
        color =  Colors.black87;
        break;
      case "confirmed":
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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
        content:
        Text("${confirmedShipments.docs.length} shipment(s) moved to Pickup."),
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