class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
  });

  /// Convert UserModel to Firestore format
  Map<String, dynamic> toMap() {
    return {'Full Name': fullName, 'Email': email, 'Password': password};
  }

  /// Convert Firestore data to UserModel
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      fullName: data['Full Name'] ?? '',
      email: data['Email'] ?? '',
      password: data['Password'] ?? '',
    );
  }
}
