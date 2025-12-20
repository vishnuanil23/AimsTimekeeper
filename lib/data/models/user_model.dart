/// MODEL: Represents user data structure
/// Purpose: Data entity for user information
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phone,
  });

  // Deserialize from JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image'],
      phone: json['phone'],
    );
  }

  // Serialize to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'phone': phone,
    };
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
    );
  }
}