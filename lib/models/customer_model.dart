class CustomerModel {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String vehicleReg;
  final String vehicleCode;
  final String gender;
  final List<Map<String, dynamic>> addresses;
  final String avatarUrl;
  final String notes;
  final String status;
  final String newsletter;
  final bool notify;

  CustomerModel({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.vehicleReg,
    required this.vehicleCode,
    required this.gender,
    required this.addresses,
    required this.avatarUrl,
    required this.notes,
    required this.status,
    required this.newsletter,
    required this.notify,
  });

  CustomerModel copyWith({
    String? username,
    String? password,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? vehicleReg,
    String? vehicleCode,
    String? gender,
    List<Map<String, dynamic>>? addresses,
    String? avatarUrl,
    String? notes,
    String? status,
    String? newsletter,
    bool? notify,
  }) {
    return CustomerModel(
      username: username ?? this.username,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      vehicleReg: vehicleReg ?? this.vehicleReg,
      vehicleCode: vehicleCode ?? this.vehicleCode,
      gender: gender ?? this.gender,
      addresses: addresses ?? this.addresses,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      newsletter: newsletter ?? this.newsletter,
      notify: notify ?? this.notify,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'vehicleReg': vehicleReg,
      'vehicleCode': vehicleCode,
      'gender': gender,
      'addresses': addresses,
      'avatarUrl': avatarUrl,
      'notes': notes,
      'status': status,
      'newsletter': newsletter,
      'notify': notify,
      // **Exclude password for security if storing elsewhere**
    };
  }
}
