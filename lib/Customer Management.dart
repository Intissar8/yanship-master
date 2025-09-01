import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Driver Management.dart';
import 'Shipment_admin_page.dart';
import 'adminProfileScreen.dart';
import 'create_shipp_admin.dart';
import 'login_screen.dart';
import 'register_client_screen.dart';
import 'CustomerProfileScreen.dart';

class CustomerManagementPage extends StatefulWidget {
  const CustomerManagementPage({super.key});

  @override
  State<CustomerManagementPage> createState() => _CustomerManagementPageState();
}

class _CustomerManagementPageState extends State<CustomerManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  Map<String, dynamic>? adminData;
  int _currentIndex = -1; // add this to state class

  Future<void> _loadAdminData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('admin')
        .doc('lQwnBDMD1rKNUiwz29Oa') // <-- replace with your admin doc ID
        .get();
    if (snapshot.exists) {
      setState(() {
        adminData = snapshot.data();
      });
    }
  }
  Widget _buildProfileAvatar(String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        // Decode base64 string into bytes
        Uint8List bytes = base64Decode(avatarUrl);
        return CircleAvatar(
          radius: 18,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        // Fallback if decoding fails
        return const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        );
      }
    } else {
      // Default avatar
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Colors.blue,
        child: Icon(Icons.person, color: Colors.white, size: 20),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
    _loadAdminData(); // load profile avatar
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CustomerManagementPage()));
                } else if (value == 'Driver List') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DriverManagementPage()));
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
            child: _buildProfileAvatar(adminData?['avatarUrl']),
          ),
        ],
      ),
    );
  }
  bool _matchesSearch(Map<String, dynamic> data) {
    final name =
    "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".toLowerCase();
    final email = (data['email'] ?? '').toLowerCase();
    final locker = (data['vehicleCode'] ?? '').toLowerCase();
    return name.contains(_searchText) ||
        email.contains(_searchText) ||
        locker.contains(_searchText);
  }

  Future<void> _deleteCustomer(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('clients').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting customer: $e")),
      );
    }
  }

  void _confirmDelete(String docId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete $name ?"),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () {
              Navigator.pop(context);
              _deleteCustomer(docId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(isMobile),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Management",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3C88)),
            ),
            const SizedBox(height: 10),

            /// ✅ Mobile : Search + bouton
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search clients by name, locker, phone, email...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3C88),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterClientScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text(
                      "Add New Customer",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                        "Search clients by name, locker, phone, email...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F3C88),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterClientScreen()),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text(
                      "Add New Customer",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                FirebaseFirestore.instance.collection('clients').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs
                      .where((doc) =>
                  doc.id != 'NeTioPfivtNtIqVRGCSZkaRKWBN2' && // <-- exclude admin
                      _matchesSearch(doc.data() as Map<String, dynamic>))
                      .toList();

                  if (users.isEmpty) {
                    return const Center(
                        child: Text(
                          "No customers found...",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ));
                  }

                  if (isMobile) {
                    // ✅ Mobile layout: Cards
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final doc = users[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name =
                            "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}";
                        final email = data['email'] ?? '';
                        final locker = data['vehicleCode'] ?? '-';
                        final status = data['status'] ?? 'inactive';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(email),
                                const SizedBox(height: 4),
                                Text("Locker: $locker"),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: status == "active"
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                        color: status == "active"
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerProfileScreen(
                                                  clientId: doc.id,
                                                  currentLang: 'en',
                                                ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.visibility,
                                          color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _confirmDelete(doc.id, name),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // ✅ Web layout: full-width DataTable
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.95,
                            maxWidth: MediaQuery.of(context).size.width * 0.95,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 12,
                                    offset: Offset(0, 6))
                              ],
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                  const Color(0xFFE8F0FE)),
                              headingTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                              dataTextStyle:
                              const TextStyle(color: Colors.black87),
                              columns: const [
                                DataColumn(label: Text("Name")),
                                DataColumn(label: Text("Email")),
                                DataColumn(label: Text("Locker")),
                                DataColumn(label: Text("Status")),
                                DataColumn(label: Text("Level")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: List.generate(users.length, (index) {
                                final doc = users[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final name =
                                    "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}";
                                final email = data['email'] ?? '';
                                final locker = data['vehicleCode'] ?? '-';
                                final status = data['status'] ?? 'inactive';
                                final rowColor = index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.withOpacity(0.05);

                                return DataRow(
                                    color: MaterialStateProperty.all(rowColor),
                                    cells: [
                                      DataCell(Text(name)),
                                      DataCell(Text(email)),
                                      DataCell(Text(locker.toString())),
                                      DataCell(Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: status == "active"
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                              color: status == "active"
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                      const DataCell(
                                          Icon(Icons.star, color: Colors.amber)),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CustomerProfileScreen(
                                                        clientId: doc.id,
                                                        currentLang: 'en',
                                                      ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.visibility,
                                                color: Colors.blue),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _confirmDelete(doc.id, name),
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                          ),
                                        ],
                                      )),
                                    ]);
                              }),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CustomerManagementPage()));
              break;
            case 3:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DriverManagementPage()));
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
}