import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

String _t(String key, String lang) {
  switch (lang) {
    case 'fr':
      return {
        "driver_profile": "Profil Chauffeur",
        "upload_photo": "Télécharger la photo",
        "personal_info": "👤 Informations personnelles",
        "vehicle_info": "🚗 Informations du véhicule",
        "settings": "⚙ Paramètres",
        "enable_notifications": "Activer les notifications",
        "newsletter_subscription": "Abonnement à la newsletter",
        "save_changes": "Enregistrer les modifications",
        "back_to_dashboard": "Retour au tableau de bord",
        "required": "Champ obligatoire",
        "invalid_email": "Email invalide",
        "yes": "Oui",
        "no": "Non",
        "username": "Nom d'utilisateur",
        "first_name": "Prénom",
        "last_name": "Nom de famille",
        "email": "Email",
        "phone": "Téléphone",
        "gender": "Genre",
        "vehicle_code": "Code du véhicule",
        "vehicle_reg": "Immatriculation",
        "addresses": "📍 Adresses",
        "status": "Statut",
        "notes": "Notes",
      }[key] ?? key;

    default:
      return {
        "driver_profile": "Driver Profile",
        "upload_photo": "Upload Photo",
        "personal_info": "👤 Personal Information",
        "vehicle_info": "🚗 Vehicle Information",
        "settings": "⚙ Settings",
        "enable_notifications": "Enable Notifications",
        "newsletter_subscription": "Newsletter Subscription",
        "save_changes": "Save Changes",
        "back_to_dashboard": "Back to Dashboard",
        "required": "Required",
        "invalid_email": "Invalid email",
        "yes": "Yes",
        "no": "No",
        "username": "Username",
        "first_name": "First Name",
        "last_name": "Last Name",
        "email": "Email",
        "phone": "Phone",
        "gender": "Gender",
        "vehicle_code": "Vehicle Code",
        "vehicle_reg": "Vehicle Reg",
        "addresses": "📍 Addresses",
        "status": "Status",
        "notes": "Notes",
      }[key] ?? key;
  }
}

class DriverProfileScreen extends StatefulWidget {
  final String currentLang;
  final String? driverId;

  const DriverProfileScreen({super.key, this.currentLang = 'en', this.driverId});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late final String uid;
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
  late TextEditingController statusCtrl;
  late TextEditingController notesCtrl;

  bool notify = false;
  String newsletter = "no";

  List<Map<String, dynamic>> addresses = [];
  Uint8List? avatarBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    uid = widget.driverId ?? FirebaseAuth.instance.currentUser!.uid;
    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data()!;
        usernameCtrl = TextEditingController(text: userData?['username'] ?? '');
        firstNameCtrl = TextEditingController(text: userData?['firstName'] ?? '');
        lastNameCtrl = TextEditingController(text: userData?['lastName'] ?? '');
        emailCtrl = TextEditingController(text: userData?['email'] ?? '');
        phoneCtrl = TextEditingController(text: userData?['phone'] ?? '');
        genderCtrl = TextEditingController(text: userData?['gender'] ?? '');
        vehicleCodeCtrl = TextEditingController(text: userData?['vehicleCode'] ?? '');
        vehicleRegCtrl = TextEditingController(text: userData?['vehicleReg'] ?? '');
        statusCtrl = TextEditingController(text: userData?['status'] ?? '');
        notesCtrl = TextEditingController(text: userData?['notes'] ?? '');
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

      await FirebaseFirestore.instance.collection('drivers').doc(uid).update({
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

    await FirebaseFirestore.instance.collection('drivers').doc(uid).update({
      "username": usernameCtrl.text,
      "firstName": firstNameCtrl.text,
      "lastName": lastNameCtrl.text,
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "gender": genderCtrl.text,
      "vehicleCode": vehicleCodeCtrl.text,
      "vehicleReg": vehicleRegCtrl.text,
      "status": statusCtrl.text,
      "notes": notesCtrl.text,
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
    final isMobile = screenWidth < 600;
    final avatarSize = isMobile ? 50.0 : 80.0;
    final spacing = isMobile ? 12.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const SizedBox(width: 8),
            Text(
              _t("driver_profile", widget.currentLang),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        centerTitle: true,
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
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              icon: const Icon(Icons.upload, color: Colors.white),
              label: Text(_t("upload_photo", widget.currentLang), style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, minimumSize: const Size.fromHeight(40)),
            ),
            const Divider(height: 30),
            Text("${firstNameCtrl.text} ${lastNameCtrl.text}",
                style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Username: ${usernameCtrl.text}"),
            _infoTile(Icons.email, Colors.blue, emailCtrl.text),
            _infoTile(Icons.phone, Colors.green, phoneCtrl.text),
            _infoTile(Icons.person, Colors.purple, "${_t("gender", widget.currentLang)}: ${genderCtrl.text}"),
            _infoTile(Icons.local_shipping, Colors.teal,
                "${_t("vehicle_code", widget.currentLang)}: ${vehicleCodeCtrl.text} (${vehicleRegCtrl.text})"),
            _infoTile(Icons.info, Colors.orange, "${_t("status", widget.currentLang)}: ${statusCtrl.text}"),
            if (addresses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t("addresses", widget.currentLang),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...addresses.map((addr) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.home, color: Colors.orange),
                    title: Text(addr['address'] ?? ''),
                    subtitle: Text("${addr['city'] ?? ''}, ${addr['country'] ?? ''} (${addr['zip'] ?? ''})"),
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
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(text),
    );
  }

  Widget _buildEditableForm({bool isMobile = false}) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _buildTextField(_t("username", widget.currentLang), usernameCtrl),
            _buildTextField(_t("first_name", widget.currentLang), firstNameCtrl),
            _buildTextField(_t("last_name", widget.currentLang), lastNameCtrl),
            _buildTextField(_t("email", widget.currentLang), emailCtrl, isEmail: true),
            _buildTextField(_t("phone", widget.currentLang), phoneCtrl),
            _buildTextField(_t("gender", widget.currentLang), genderCtrl),
            _buildTextField(_t("status", widget.currentLang), statusCtrl),
            _buildTextField(_t("notes", widget.currentLang), notesCtrl, maxLines: 2),
            const Divider(height: 30),
            Align(
              alignment: Alignment.centerLeft, // ensures title is at the start
              child: Text(
                _t("vehicle_info", widget.currentLang),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            _buildTextField(_t("vehicle_code", widget.currentLang), vehicleCodeCtrl),
            _buildTextField(_t("vehicle_reg", widget.currentLang), vehicleRegCtrl),
            const Divider(height: 30),
            SwitchListTile(
              value: notify,
              onChanged: (val) => setState(() => notify = val),
              title: Text(_t("enable_notifications", widget.currentLang)),
            ),
            DropdownButtonFormField<String>(
              value: newsletter,
              items: [
                DropdownMenuItem(value: "yes", child: Text(_t("yes", widget.currentLang))),
                DropdownMenuItem(value: "no", child: Text(_t("no", widget.currentLang))),
              ],
              onChanged: (val) => setState(() => newsletter = val ?? "no"),
              decoration: InputDecoration(labelText: _t("newsletter_subscription", widget.currentLang)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(45)),
                    onPressed: isLoading ? null : _updateProfile,
                    icon: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save, color: Colors.white),
                    label: Text(_t("save_changes", widget.currentLang), style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.dashboard),
                    label: Text(_t("back_to_dashboard", widget.currentLang)),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue.shade600, minimumSize: const Size.fromHeight(45)),
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
      {bool isEmail = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: (v) {
          if (v == null || v.isEmpty) return _t("required", widget.currentLang);
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
            return _t("invalid_email", widget.currentLang);
          }
          return null;
        },
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}