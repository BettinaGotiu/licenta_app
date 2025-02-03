import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'signin_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'domain_selection_screen.dart';
import 'daily_challenge_screen.dart';
import 'personalized_words_page.dart';
import 'history_screen.dart';
import 'speed_selection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User? user;
  String? username;
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _sessions = [];
  Set<DateTime> _sessionDates = {}; // Using Set for quick lookup
  bool _showLastFiveSessions = true;
  int _selectedIndex = 0;

  // New color palette
  final Color primaryColor = Color(0xFF3539AC); // rgba(53,37,172,255)
  final Color secondaryColor = Color(0xFF11BDE3); // rgba(17,189,227,255)
  final Color accentColor = Color(0xFFFF3926); // rgba(255,57,38,255)
  final Color cardColor = Color(0xFF973462); // rgba(151,52,98,255)
  final Color chartLineColor = Color(0xFF7670B9); // rgba(118,112,185,255)
  final Color backgroundColor = Color(0xFFEFF3FE); // rgba(239,243,254,255)
  final Color textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchSessionData();
    _fetchUsername();
  }

  Future<void> _fetchSessionData() async {
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .collection('sessions')
          .orderBy('date')
          .get();

      setState(() {
        _sessions = snapshot.docs.map((doc) => doc.data()).toList();
        _sessionDates = snapshot.docs.map((doc) {
          DateTime date = DateTime.parse(doc['date']);
          return DateTime(
              date.year, date.month, date.day); // Normalize date to YYYY-MM-DD
        }).toSet();
      });
    }
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .get();

      setState(() {
        username = doc['username'];
      });
    }
  }

  bool _isSessionDate(DateTime date) {
    return _sessionDates.contains(DateTime(date.year, date.month, date.day));
  }

  void _navigateToSpeedSelection(BuildContext context, String nextPageRoute) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeedSelectionPage(nextPageRoute: nextPageRoute),
      ),
    );
  }

  Widget _buildLineChart() {
    List<Map<String, dynamic>> sessionsToShow = _showLastFiveSessions
        ? _sessions
            .skip(_sessions.length > 5 ? _sessions.length - 5 : 0)
            .toList()
        : _sessions;

    List<ChartLineDataItem> dataPoints = sessionsToShow
        .asMap()
        .entries
        .map((entry) => ChartLineDataItem(
              x: entry.key.toDouble() + 1,
              value: entry.value['withinLimitPercentage'].toDouble(),
            ))
        .toList();

    List<String> dateLabels = sessionsToShow
        .map((session) => DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(session['date'] as String)))
        .toList();

    return _sessions.isEmpty
        ? Container(
            height: 200,
            child: Center(
              child: Text(
                'No session data available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        : Container(
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
                Text(
                  'Your Progress Over Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This chart shows how well your speech fits within the selected speed limits over time. Higher percentages indicate better alignment with the speed limit.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _showLastFiveSessions
                            ? primaryColor
                            : Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showLastFiveSessions = true;
                        });
                      },
                      child: Text(
                        'Last 5 Sessions',
                        style: TextStyle(
                          color:
                              _showLastFiveSessions ? Colors.white : textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_showLastFiveSessions
                            ? primaryColor
                            : Colors.grey[200],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showLastFiveSessions = false;
                        });
                      },
                      child: Text(
                        'All Time Progress',
                        style: TextStyle(
                          color:
                              !_showLastFiveSessions ? Colors.white : textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: dataPoints.length * 100.0,
                    height: 200,
                    child: Chart(
                      layers: [
                        ChartAxisLayer(
                          settings: ChartAxisSettings(
                            x: ChartAxisSettingsAxis(
                              frequency: 1.0,
                              max: dataPoints.length.toDouble(),
                              min: 1.0,
                              textStyle:
                                  TextStyle(color: textColor, fontSize: 12.0),
                            ),
                            y: ChartAxisSettingsAxis(
                              frequency: 10.0,
                              max: 100.0,
                              min: 0.0,
                              textStyle:
                                  TextStyle(color: textColor, fontSize: 12.0),
                            ),
                          ),
                          labelX: (value) => dateLabels[value.toInt() - 1],
                          labelY: (value) => value.toString(),
                        ),
                        ChartLineLayer(
                          items: dataPoints,
                          settings: ChartLineSettings(
                            color: chartLineColor,
                            thickness: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Scroll for more data',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          );
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      _showLogoutConfirmation();
    } else {
      setState(() {
        _selectedIndex = index;
      });
      switch (index) {
        case 0:
          // Home is the current screen
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PersonalizedWordsPage()),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
          break;
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140.0),
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
                padding: const EdgeInsets.only(top: 10.0, right: 100.0),
                child: Text(
                  username != null ? 'Welcome, $username' : 'Welcome',
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
              // Daily Streak Calendar
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Streak',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CalendarScreen()),
                              );
                            },
                            child: Text(
                              'Full Streak Calendar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.week,
                        onFormatChanged: (format) {},
                        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                        locale: 'en_US',
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, _) {
                            if (_isSessionDate(day)) {
                              return Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                            return Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                          todayBuilder: (context, day, _) {
                            if (_isSessionDate(day)) {
                              return Container(
                                margin: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }
                            return Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Real-Time Sessions Card
              buildCard(
                title: "Real-Time Sessions",
                description: "Engage in live sessions with our tool.",
                context: context,
                onTap: () {
                  _navigateToSpeedSelection(context, '/speech_to_text');
                },
              ),
              const SizedBox(height: 10),

              // Practice Exercises Card
              buildCard(
                title: "Practice Exercises",
                description: "Enhance your skills with practice tasks.",
                context: context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DomainSelectionPage()),
                  );
                },
              ),
              const SizedBox(height: 10),

              // Daily Challenge Card
              buildCard(
                title: "Daily Challenge",
                description: "Try a new challenge every day.",
                context: context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DailyChallengePage()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Progress Over Time Chart
              _buildLineChart(),
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
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Container(
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: Icon(Icons.play_circle_fill, color: primaryColor, size: 40),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
        onTap: onTap,
      ),
    );
  }
}
