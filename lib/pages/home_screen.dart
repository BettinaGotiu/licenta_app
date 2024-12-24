import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'signin_screen.dart';
import 'speech_to_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User? user;
  DateTime _focusedDay = DateTime.now(); // Current focused day
  DateTime? _selectedDay; // Selected day on the calendar

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'Settings') {
                // Navigate to settings (route to be implemented later)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Settings route not implemented')),
                );
              } else if (value == 'Logout') {
                // Logout logic
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SigninScreen()),
                    (route) => false,
                  );
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
              const PopupMenuItem(value: 'Logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calendar (Minimalistic version)
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarFormat: CalendarFormat.week, // Minimalistic row version
              onFormatChanged: (format) {}, // Disable format change for now
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              locale: 'en_US', // Language set to English
            ),
            const SizedBox(height: 20),
            // Cards Layout
            Expanded(
              child: ListView(
                children: [
                  buildCard(
                    title: "Real-Time Sessions",
                    description: "Engage in live sessions with our tool.",
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SpeechToTextPage(),
                        ),
                      );
                    },
                  ),
                  buildCard(
                    title: "Practice Exercises",
                    description: "Enhance your skills with practice tasks.",
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SpeechToTextPage(),
                        ),
                      );
                    },
                  ),
                  buildCard(
                    title: "Daily Challenge",
                    description: "Try a new challenge every day.",
                    context: context,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SpeechToTextPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String description,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: const Text("Start"),
        ),
      ),
    );
  }
}
