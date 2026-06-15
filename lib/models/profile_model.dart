class ProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profileImage;
  final bool? isVerified;

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.profileImage,
    this.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      isVerified: json['is_verified'],
    );
  }
}
