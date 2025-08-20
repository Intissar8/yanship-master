import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? userData;
  bool isLoading = false;

  late TextEditingController usernameCtrl;
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController genderCtrl;
  late TextEditingController vehicleCodeCtrl;
  late TextEditingController vehicleRegCtrl;

  bool notify = false;
  String newsletter = "no";

  List<Map<String, dynamic>> addresses = [];
  Uint8List? avatarBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final doc =
    await FirebaseFirestore.instance.collection('clients').doc(uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data()!;
        usernameCtrl = TextEditingController(text: userData?['username'] ?? '');
        firstNameCtrl =
            TextEditingController(text: userData?['firstName'] ?? '');
        lastNameCtrl = TextEditingController(text: userData?['lastName'] ?? '');
        emailCtrl = TextEditingController(text: userData?['email'] ?? '');
        phoneCtrl = TextEditingController(text: userData?['phone'] ?? '');
        genderCtrl = TextEditingController(text: userData?['gender'] ?? '');
        vehicleCodeCtrl =
            TextEditingController(text: userData?['vehicleCode'] ?? '');
        vehicleRegCtrl =
            TextEditingController(text: userData?['vehicleReg'] ?? '');
        notify = userData?['notify'] ?? false;
        newsletter = userData?['newsletter'] ?? "no";
        addresses = List<Map<String, dynamic>>.from(userData?['addresses'] ?? []);

        if (userData?['avatarUrl'] != null && userData!['avatarUrl']!.isNotEmpty) {
          try {
            avatarBytes = base64Decode(userData!['avatarUrl']);
          } catch (_) {
            avatarBytes = null;
          }
        }
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => isLoading = true);

    try {
      Uint8List bytes = await picked.readAsBytes();
      String base64Str = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('clients').doc(uid).update({
        "avatarUrl": base64Str,
      });

      setState(() {
        avatarBytes = bytes;
      });
    } catch (e) {
      debugPrint("Image save failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save image")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    await FirebaseFirestore.instance.collection('clients').doc(uid).update({
      "username": usernameCtrl.text,
      "firstName": firstNameCtrl.text,
      "lastName": lastNameCtrl.text,
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "gender": genderCtrl.text,
      "vehicleCode": vehicleCodeCtrl.text,
      "vehicleReg": vehicleRegCtrl.text,
      "notify": notify,
      "newsletter": newsletter,
      "addresses": addresses,
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profile updated successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // mobile breakpoint
    final avatarSize = isMobile ? 50.0 : 80.0;
    final spacing = isMobile ? 12.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Profile"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
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
    );
  }

  Widget _buildProfileCard(ThemeData theme, {double avatarSize = 50}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: avatarSize,
              backgroundColor: Colors.blue.shade100,
              backgroundImage:
              avatarBytes != null ? MemoryImage(avatarBytes!) : null,
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
                padding: EdgeInsets.symmetric(
                    horizontal: avatarSize, vertical: avatarSize * 0.2),
              ),
            ),
            SizedBox(height: 16),
            Text("${firstNameCtrl.text} ${lastNameCtrl.text}",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Username: ${usernameCtrl.text}",
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const Divider(height: 24),
            _infoTile(Icons.email, Colors.blue, emailCtrl.text),
            _infoTile(Icons.phone, Colors.green, phoneCtrl.text),
            _infoTile(Icons.person_outline, Colors.purple, "Gender: ${genderCtrl.text}"),
            _infoTile(Icons.local_shipping, Colors.teal,
                "Vehicle: ${vehicleCodeCtrl.text} (${vehicleRegCtrl.text})"),
            const Divider(),
            if (addresses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📍 Addresses:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...addresses.map((addr) => ListTile(
                    leading: const Icon(Icons.home, color: Colors.orange),
                    title: Text(addr['address'] ?? ''),
                    subtitle: Text(
                        "${addr['city'] ?? ''}, ${addr['country'] ?? ''} (${addr['zip'] ?? ''})"),
                  )),
                ],
              ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("👤 Personal Information"),
            _buildTextField("Username", usernameCtrl, isMobile: isMobile),
            _buildTextField("First Name", firstNameCtrl, isMobile: isMobile),
            _buildTextField("Last Name", lastNameCtrl, isMobile: isMobile),
            _buildTextField("Email", emailCtrl, isEmail: true, isMobile: isMobile),
            _buildTextField("Phone", phoneCtrl, isMobile: isMobile),
            _buildTextField("Gender", genderCtrl, isMobile: isMobile),
            const SizedBox(height: 16),
            _sectionTitle("🚗 Vehicle Information"),
            _buildTextField("Vehicle Code", vehicleCodeCtrl, isMobile: isMobile),
            _buildTextField("Vehicle Reg", vehicleRegCtrl, isMobile: isMobile),
            const SizedBox(height: 16),
            _sectionTitle("⚙️ Settings"),
            SwitchListTile(
              value: notify,
              onChanged: (val) => setState(() => notify = val),
              title: const Text("Enable Notifications"),
            ),
            DropdownButtonFormField<String>(
              value: newsletter,
              items: const [
                DropdownMenuItem(value: "yes", child: Text("Yes")),
                DropdownMenuItem(value: "no", child: Text("No")),
              ],
              onChanged: (val) => setState(() => newsletter = val ?? "no"),
              decoration:
              const InputDecoration(labelText: "Newsletter Subscription"),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    onPressed: isLoading ? null : _updateProfile,
                    icon: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.save),
                    label: const Text("Save Changes"),
                  ),
                ),
                SizedBox(
                  width: isMobile ? double.infinity : null,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.dashboard),
                    label: const Text("Back to Dashboard"),
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
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
            return "Invalid email";
          }
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
          contentPadding:
          EdgeInsets.symmetric(horizontal: 12, vertical: isMobile ? 12 : 16),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child:
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}
