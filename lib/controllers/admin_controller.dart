import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

class AdminController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Save new admin details to Firestore
  Future<void> saveAdmin(Admin admin) async {
    try {
      await _firestore.collection('admins').add(admin.toMap());
      print("✅ Admin added successfully!");
    } catch (e) {
      print("❌ Error adding admin: $e");
    }
  }

  /// ✅ Retrieve all admins (or filter by email)
  Future<List<Admin>> fetchAllAdmins() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('admins').get();

      return snapshot.docs
          .map(
            (doc) => Admin.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print("❌ Error fetching admins: $e");
      return [];
    }
  }

  /// ✅ Get single admin by email
  Future<Admin?> getAdminByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('admins')
          .where('Email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Admin.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        print("⚠️ No admin found with that email");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching admin: $e");
      return null;
    }
  }

  Future<Admin?> loginAdmin(String email, String password) async {
    try {
      // Query Firestore collection for matching email.
      final snapshot = await _firestore
          .collection('admins')
          .where('Email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        // No admin found
        print("❌ No admin found with email: $email");
        return null;
      }

      // Extract admin data from Firestore
      final doc = snapshot.docs.first;
      final adminData = doc.data();

      // Compare stored password
      if (adminData['Password'] == password) {
        print("✅ Admin login successful for $email");
        return Admin.fromMap(doc.id, adminData);
      } else {
        print("❌ Incorrect password for admin: $email");
        return null;
      }
    } catch (e) {
      print("⚠️ Login error: $e");
      return null;
    }
  }

  Future<Admin?> getAdminDetails(String adminId) async {
    try {
      final doc = await _firestore.collection('admins').doc(adminId).get();
      if (doc.exists) {
        return Admin.fromMap(doc.id, doc.data()!);
      } else {
        print("❌ Admin not found");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching admin details: $e");
      return null;
    }
  }
}
