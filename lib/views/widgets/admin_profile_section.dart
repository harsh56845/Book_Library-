// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:book_villa/controllers/admin_controller.dart';
import 'package:book_villa/models/admin_model.dart';

class AdminProfileSection extends StatefulWidget {
  String adminId;
  AdminProfileSection({super.key, required this.adminId});

  @override
  State<AdminProfileSection> createState() => _AdminProfileSectionState();
}

class _AdminProfileSectionState extends State<AdminProfileSection> {
  final AdminController _adminController = AdminController();
  Admin? admin;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminDetails();
  }

  Future<void> _loadAdminDetails() async {
    String adminId = widget.adminId;

    final fetchedAdmin = await _adminController.getAdminDetails(adminId);
    setState(() {
      admin = fetchedAdmin;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (admin == null) {
      return const Center(
        child: Text(
          "❌ Unable to load admin details",
          style: TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF6C63FF),
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "👤 Admin: ${admin!.name}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            "📧 ${admin!.email}",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            "🆔 Admin ID: ${admin!.email}",
            style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
