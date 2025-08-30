import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'Shipment_admin_page.dart';
import 'create_shipp_admin.dart';
import 'login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  final String currentLang;
  const AdminProfileScreen({super.key, this.currentLang = 'en'});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final String adminUid = "lQwnBDMD1rKNUiwz29Oa";
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int _currentIndex = -1; // 0 = Profile, 1 = Create Shipment, 2 = Shipment List, 3 = Customer List, 4 = Driver List


  Map<String, dynamic>? adminData;
  Uint8List? avatarBytes;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(adminUid)
          .get();

      if (!mounted) return;

      if (doc.exists) {
        adminData = doc.data()!;
        firstNameCtrl = TextEditingController(text: adminData?['firstName'] ?? '');
        lastNameCtrl = TextEditingController(text: adminData?['lastName'] ?? '');
        emailCtrl = TextEditingController(text: adminData?['email'] ?? '');
        addressCtrl = TextEditingController(text: adminData?['address'] ?? '');

        if (adminData?['avatarUrl'] != null && adminData!['avatarUrl'].isNotEmpty) {
          try {
            avatarBytes = base64Decode(adminData!['avatarUrl']);
          } catch (_) {
            avatarBytes = null;
          }
        }
      } else {
        // Safe fallback if document doesn't exist
        adminData = {};
        firstNameCtrl = TextEditingController();
        lastNameCtrl = TextEditingController();
        emailCtrl = TextEditingController();
        addressCtrl = TextEditingController();
      }

      setState(() {}); // Trigger UI rebuild
    } catch (e) {
      debugPrint("Failed to load admin data: $e");
      adminData = {};
      firstNameCtrl = TextEditingController();
      lastNameCtrl = TextEditingController();
      emailCtrl = TextEditingController();
      addressCtrl = TextEditingController();
      setState(() {});
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);

    try {
      Uint8List bytes = await picked.readAsBytes();
      String base64Str = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('admin').doc(adminUid).update({
        "avatarUrl": base64Str,
      });

      setState(() {
        avatarBytes = bytes;
        adminData!['avatarUrl'] = base64Str;
      });
    } catch (e) {
      debugPrint("Image save failed: $e");

    }

    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('admin').doc(adminUid).update({
        "firstName": firstNameCtrl.text,
        "lastName": lastNameCtrl.text,
        "email": emailCtrl.text,
        "address": addressCtrl.text,
      });

      // Update local adminData so UI shows changes immediately
      adminData!['firstName'] = firstNameCtrl.text;
      adminData!['lastName'] = lastNameCtrl.text;
      adminData!['email'] = emailCtrl.text;
      adminData!['address'] = addressCtrl.text;

      setState(() => isLoading = false);


    } catch (e) {
      debugPrint("Failed to update profile: $e");
      setState(() => isLoading = false);

    }
  }
  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 16,
      title: Row(
        children: [
          // Company logo
          Image.asset('assets/images/logo.png', height: 40),
          if (!isMobile) ...[
            const SizedBox(width: 24),

            // Shipments Dropdown
            PopupMenuButton<String>(
              child: Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.grey[800], size: 22),
                  const SizedBox(width: 6),
                  Text('Shipments', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[800], size: 22),
                ],
              ),
              onSelected: (value) {
                if (value == 'Create Shipment') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentFormStyledPage()));
                } else if (value == 'Shipment List') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentsTablePage()));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Create Shipment', child: Row(children: [Icon(Icons.add), SizedBox(width: 8), Text('Create Shipment')])),
                const PopupMenuItem(value: 'Shipment List', child: Row(children: [Icon(Icons.list), SizedBox(width: 8), Text('Shipment List')])),
              ],
            ),

            const SizedBox(width: 24),

            // Users Dropdown
            PopupMenuButton<String>(
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[800], size: 22),
                  const SizedBox(width: 6),
                  Text('Users', style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[800], size: 22),
                ],
              ),
              onSelected: (value) {
                // Handle navigation for Customers & Drivers
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Customer List', child: Row(children: [Icon(Icons.people), SizedBox(width: 8), Text('Customer List')])),
                const PopupMenuItem(value: 'Driver List', child: Row(children: [Icon(Icons.drive_eta), SizedBox(width: 8), Text('Driver List')])),
              ],
            ),
          ],
          const Spacer(),

          // Language Dropdown (web + mobile)
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

          // Profile Circle with menu
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen()));
              } else if (value == 'logout') {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
    if (adminData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final avatarSize = isMobile ? 50.0 : 80.0;
    final spacing = isMobile ? 12.0 : 20.0;

    return Scaffold(
      appBar: _buildAppBar(isMobile),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing),
        child: Form(
          key: _formKey,
          child: isMobile
              ? Column(
            children: [
              _buildProfileCard(theme, avatarSize: avatarSize),
              SizedBox(height: spacing),
              _buildEditableForm(isMobile: true),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildProfileCard(theme, avatarSize: avatarSize)),
              SizedBox(width: spacing),
              Expanded(flex: 5, child: _buildEditableForm()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12, // same as unselected
        unselectedFontSize: 12,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex < 0 ? 0 : _currentIndex, // prevent errors
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentFormStyledPage()));
              break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShipmentsTablePage()));
              break;
            case 2:
            // Customer List
              break;
            case 3:
            // Driver List
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

  Widget _buildProfileCard(ThemeData theme, {double avatarSize = 50}) {
    return Card(
      color: Colors.white, // Card background white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: avatarSize,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes!) : null,
              child: avatarBytes == null
                  ? Icon(Icons.person, size: avatarSize, color: Colors.blue)
                  : null,
            ),
            SizedBox(height: avatarSize * 0.2),
            ElevatedButton.icon(
              onPressed: _pickAndSaveImage,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Photo"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: avatarSize, vertical: avatarSize * 0.2),
                foregroundColor: Colors.white, // Text color white
                backgroundColor: Colors.blue.shade600, // Button color
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${adminData?['firstName'] ?? ''} ${adminData?['lastName'] ?? ''}",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _infoTile(Icons.email, Colors.blue, adminData?['email'] ?? ''),
            _infoTile(Icons.home, Colors.orange, adminData?['address'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, Color color, String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(text),
    );
  }

  Widget _buildEditableForm({bool isMobile = false}) {
    return Card(
      color: Colors.white, // Card background white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("First Name", firstNameCtrl, isMobile: isMobile),
            _buildTextField("Last Name", lastNameCtrl, isMobile: isMobile),
            _buildTextField("Email", emailCtrl, isEmail: true, isMobile: isMobile),
            _buildTextField("Address", addressCtrl, isMobile: isMobile),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onPressed: isLoading ? null : _updateProfile,
                    icon: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.save),
                    label: const Text("Save Changes"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShipmentsTablePage()),
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text("Dashboard"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField(String label, TextEditingController controller,
      {bool isEmail = false, bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: (v) {
          if (v == null || v.isEmpty) return "Required";
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return "Invalid email";
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: isMobile ? 12 : 16),
        ),
      ),
    );
  }
}
