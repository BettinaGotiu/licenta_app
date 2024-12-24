import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signin_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _passwordController = TextEditingController();
  late User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  // Function to update the password
  Future<void> _updatePassword() async {
    try {
      await user?.updatePassword(_passwordController.text);
      Navigator.of(context).pop(); // Close the dialog after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating password: $e")),
      );
    }
  }

  // Function to show a popup dialog for entering a new password
  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Password"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Enter New Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: _updatePassword, // Call the password update function
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  // Function to show the delete confirmation dialog
  Future<void> _confirmDeleteAccount() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteAccount();
    }
  }

  // Function to delete the account
  Future<void> _deleteAccount() async {
    try {
      await user?.delete();
      // Navigate to the SignInScreen after successful account deletion
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SigninScreen()),
        (route) => false, // Remove all previous routes
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Display email of the current user
            Text(
              "Email: ${user?.email ?? 'Unknown'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPasswordDialog, // Show dialog for password update
              child: const Text("Update Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmDeleteAccount, // Show confirmation dialog
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }
}
