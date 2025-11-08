class Admin {
  final String id;
  final String name;
  final String email;
  final String password;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // Convert admin object to Map
  Map<String, dynamic> toMap() {
    return {'Full Name': name, 'Email': email, 'Password': password};
  }

  // Convert Firestore document to Admin object
  factory Admin.fromMap(String id, Map<String, dynamic> data) {
    return Admin(
      id: id,
      name: data['Full Name'] ?? data['name'] ?? 'Unknown Admin',
      email: data['Email'] ?? data['email'] ?? 'No Email',
      password: data['Password'] ?? '******',
    );
  }
}
