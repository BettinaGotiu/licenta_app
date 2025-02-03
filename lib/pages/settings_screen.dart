import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'signin_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'personalized_words_page.dart'; // Import the Filler Words screen

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
  int _selectedIndex = 3; // Highlight the User widget
  bool _passwordVisible = false;
  Color _borderColor = Colors.transparent;
  double _borderThickness = 2.0;

  // New color palette
  final Color primaryColor = Color(0xFF3539AC); // rgba(53,37,172,255)
  final Color secondaryColor = Color(0xFF11BDE3); // rgba(17,189,227,255)
  final Color accentColor = Color(0xFFFF3926); // rgba(255,57,38,255)
  final Color backgroundColor = Color(0xFFEFF3FE); // rgba(239,243,254,255)
  final Color textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _usernameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
  }

  Future<bool> _reauthenticateUser() async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: _passwordController.text,
      );
      await user?.reauthenticateWithCredential(credential);
      setState(() {
        _borderColor = Colors.green;
        _borderThickness = 3.0;
      });
      return true;
    } catch (e) {
      setState(() {
        _borderColor = Colors.red;
        _borderThickness = 3.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error re-authenticating user: $e")),
      );
      return false;
    }
  }

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

  void _showPasswordDialog() {
    _passwordController.clear();
    _passwordVisible = false;
    _borderColor = Colors.transparent;
    _borderThickness = 2.0;
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

  Future<void> _updateUsername(
      BuildContext context, StateSetter setState) async {
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
        _borderColor = Colors.green;
        _borderThickness = 3.0;
      });

      // Show success and close dialog after a delay
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop(); // Close the dialog
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating username: $e")),
      );
    }
  }

  void _showUsernameDialog() {
    _usernameController.text =
        user?.displayName ?? ''; // Reset to original value
    _passwordController.clear(); // Clear the password field initially
    _passwordVisible = false; // Reset password visibility to hidden
    _borderColor = Colors.transparent; // Reset border color
    _borderThickness = 2.0; // Reset border thickness
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Username"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration:
                        const InputDecoration(labelText: "Enter New Username"),
                  ),
                  SizedBox(height: 20), // Add space between fields
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Enter Password to Confirm",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Close dialog
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool success = await _reauthenticateUser();
                    if (success) {
                      _updateUsername(context, setState);
                    } else {
                      setState(() {
                        _borderColor = Colors.red;
                        _borderThickness = 3.0;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Incorrect password. Please try again.")),
                      );
                    }
                  },
                  child: const Text("Confirm"),
                ),
              ],
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: _borderColor,
                  width: _borderThickness,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateEmail(BuildContext context, StateSetter setState) async {
    bool reauthenticated = await _reauthenticateUser();
    if (reauthenticated) {
      try {
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
          _borderColor = Colors.green;
          _borderThickness = 3.0;
        });

        // Show success and close dialog after a delay
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop(); // Close the dialog
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating email: $e")),
        );
      }
    } else {
      setState(() {
        _borderColor = Colors.red;
        _borderThickness = 3.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect password. Please try again.")),
      );
    }
  }

  void _showEmailDialog() {
    _emailController.text = user?.email ?? ''; // Reset to original value
    _passwordController.clear(); // Clear the password field initially
    _passwordVisible = false; // Reset password visibility to hidden
    _borderColor = Colors.transparent; // Reset border color
    _borderThickness = 2.0; // Reset border thickness
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Email"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration:
                        const InputDecoration(labelText: "Enter New Email"),
                  ),
                  SizedBox(height: 20), // Add space between fields
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: "Enter Password to Confirm",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Close dialog
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => _updateEmail(context, setState),
                  child: const Text("Confirm"),
                ),
              ],
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: _borderColor,
                  width: _borderThickness,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        );
      },
    );
  }

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

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const PersonalizedWordsPage()), // Navigate to Filler Words screen
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.0),
        child: ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 220.0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Nacelle',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Update Password Card
              buildCard(
                title: "Update Password",
                description: "Change your account password.",
                onTap: _showPasswordDialog,
                icon: Icons.lock,
              ),
              const SizedBox(height: 10),

              // Logout Card
              buildCard(
                title: "Logout",
                description: "Sign out of your account.",
                onTap: _logout,
                icon: Icons.logout, // Door leaving icon
              ),
              const SizedBox(height: 10),

              // Delete Account Card
              buildCard(
                title: "Delete Account",
                description: "Permanently delete your account.",
                onTap: _confirmDeleteAccount,
                icon: Icons.delete, // Garbage icon
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, size: 24),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note, size: 24),
              label: 'Filler Words',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24),
              label: 'User',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout, size: 24),
              label: 'Logout',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String description,
    required VoidCallback onTap,
    IconData icon = Icons.settings, // Default icon
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: Icon(icon,
            color: isDestructive ? Color(0xFF3539AC) : primaryColor,
            size: 30), // Reduced size
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold), // Reduced font size
        ),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios,
            color: primaryColor, size: 20), // Reduced size
        onTap: onTap,
      ),
    );
  }
}
