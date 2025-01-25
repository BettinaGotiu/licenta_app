import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signin_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late User? user;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _usernameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  // Function to re-authenticate the user
  Future<void> _reauthenticateUser() async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: _passwordController.text,
      );
      await user?.reauthenticateWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error re-authenticating user: $e")),
      );
    }
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

  // Function to update the username
  Future<void> _updateUsername() async {
    try {
      await user?.updateDisplayName(_usernameController.text.trim());
      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user?.uid)
          .update({'username': _usernameController.text.trim()});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username updated successfully")),
      );
      setState(() {
        // Update the local display name immediately
        user = FirebaseAuth.instance.currentUser;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating username: $e")),
      );
    }
  }

  // Function to show a popup dialog for entering a new username
  void _showUsernameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Username"),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: "Enter New Username"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUsername();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  // Function to update the email
  Future<void> _updateEmail() async {
    try {
      await _reauthenticateUser(); // Re-authenticate the user before updating email
      await user?.updateEmail(_emailController.text.trim());
      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user?.uid)
          .update({'email': _emailController.text.trim()});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email updated successfully")),
      );
      setState(() {
        // Update the local email immediately
        user = FirebaseAuth.instance.currentUser;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating email: $e")),
      );
    }
  }

  // Function to show a popup dialog for entering a new email
  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Email"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Enter New Email"),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Enter Password to Confirm"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateEmail();
                Navigator.of(context).pop(); // Close the dialog
              },
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

  // Function to log out the user
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Username: ${user?.displayName ?? 'Unknown'}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showUsernameDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Email: ${user?.email ?? 'Unknown'}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _showEmailDialog,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showPasswordDialog, // Show dialog for password update
              child: const Text("Update Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout, // Logout the user
              child: const Text("Logout"),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
