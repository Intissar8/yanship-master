import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomerProfileScreen.dart';
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_t("dashboard_customer", _currentLang)),
        backgroundColor: Colors.blue.shade800,
        elevation: 2,
        actions: [
          DropdownButton<String>(
            value: _currentLang,
            dropdownColor: Colors.blue.shade800,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currentLang = value;
                  // Optional: update app locale if you use a localization provider
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
                  MaterialPageRoute(builder: (_) =>   CustomerProfileScreen(currentLang: _currentLang),
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
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(_t("view_profile", _currentLang)),
                  ],
                ),
              ),
               PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(_t("logout", _currentLang)),
                  ],
                ),
              ),
            ],
            // 👉 Ici on affiche l’avatar du client s’il existe
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
                    backgroundColor: Colors.white,
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

  /// WEB VERSION
  Widget _buildWebView(List<QueryDocumentSnapshot> filteredDocs) {
    final tableHeight = MediaQuery.of(context).size.height - 200;

    return SizedBox(
      height: tableHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 700,
              maxWidth: 1200,
            ),
            child: Column(
              children: List.generate(filteredDocs.length + 1, (index) {
                if (index == 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    color: Colors.blue.shade100,
                    child: Row(
                      children:  [
                        SizedBox(
                            width: 200,
                            child: Text(_t("name", _currentLang),
                                style:
                                TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 150,
                            child: Text(_t("city", _currentLang),
                                style:
                                TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 100,
                            child: Text(_t("price", _currentLang),
                                style:
                                TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 150,
                            child: Text(_t("status", _currentLang),
                                style:
                                TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 250,
                            child: Text(_t("actions", _currentLang),
                                style:
                                TextStyle(fontWeight: FontWeight.bold))),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                        Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 200, child: Text(data['receiverName'] ?? "")),
                          SizedBox(width: 150, child: Text(data['city'] ?? "")),
                          SizedBox(
                              width: 100,
                              child: Text("MAD ${data['price'] ?? ''}")),
                          SizedBox(
                              width: 150, child: _buildStatusChip(status)),
                          SizedBox(
                            width: 250,
                            child: Row(
                              children: [
                                if (statusNormalized == 'created' ||
                                    statusNormalized == 'pickup' ||
                                    statusNormalized == 'confirmed')
                                  _buildActionsMenu(doc.id, data, statusNormalized),
                                IconButton(
                                  icon: Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
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
                            _buildDetailRow(_t("address", _currentLang), data['address'] ?? 'N/A'),
                            _buildDetailRow(_t("phone", _currentLang), data['phone'] ?? 'N/A'),
                            _buildDetailRow(_t("created_at", _currentLang), data['createdAt']?.toDate().toString() ?? 'N/A'),
                          ],
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// Top controls with new Profile button
  Widget _buildTopControls(bool isMobile) {
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
        alignment: WrapAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddShipmentScreen(currentLang: _currentLang),
                  ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label:  Text(_t("create_order", _currentLang),
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: _pickupAllConfirmed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child:  Text(_t("pickup", _currentLang),
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          /*ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerProfileScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.person, color: Colors.white),
            label:  Text(_t("profile", _currentLang),
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),*/
          SizedBox(
            width: isMobile ? 120 : 150,
            child: _buildSearchField(_t("tracking_id", _currentLang)),
          ),
          SizedBox(
            width: isMobile ? 150 : 200,
            child: _buildSearchField(_t("search_tracking", _currentLang), onChanged: (value) {
              setState(() => searchQuery = value.toLowerCase());
            }),
          ),
          DropdownButton<String>(
            value: statusFilter.isEmpty ? null : statusFilter,
            hint: Text("-- ${_t("status", _currentLang)} --"), // translated hint
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(value: "", child: Text(_t("all", _currentLang))),
              DropdownMenuItem(value: "Created", child: Text(_t("created", _currentLang))),
              DropdownMenuItem(value: "Pickup", child: Text(_t("pickup", _currentLang))),
              DropdownMenuItem(value: "Confirmed", child: Text(_t("confirmed", _currentLang))),
            ],
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
          // TODO: print logic
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
        color = Colors.lightBlue;
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