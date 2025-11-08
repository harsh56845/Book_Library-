import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Create a new user account in Firestore
  Future<bool> createUser(UserModel user) async {
    try {
      // Check if user with same email exists
      final existing = await _firestore
          .collection('users')
          .where('Email', isEqualTo: user.email)
          .get();

      if (existing.docs.isNotEmpty) {
        print("⚠️ User with this email already exists!");
        return false;
      }

      // Save new user
      await _firestore.collection('users').add(user.toMap());
      print("✅ User registered successfully!");
      return true;
    } catch (e) {
      print("❌ Error creating user: $e");
      return false;
    }
  }

  Future<UserModel?> loginUser(String email, String password) async {
    try {
      // Fetch the user with matching email
      final snapshot = await _firestore
          .collection('users')
          .where('Email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        print("⚠️ No user found with this email.");
        return null;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      if (data['Password'] == password) {
        print("✅ Login successful for user: $email");
        return UserModel.fromMap(doc.id, data);
      } else {
        print("❌ Invalid password for $email");
        return null;
      }
    } catch (e) {
      print("❌ Error logging in: $e");
      return null;
    }
  }
}
