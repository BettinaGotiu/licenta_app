import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'signin_screen.dart';
import 'speech_to_text.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'domain_selection_screen.dart';
import 'daily_challenge_screen.dart';
import 'personalized_words_page.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User? user;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _sessions = [];
  bool _showLastFiveSessions = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchSessionData();
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
      });
    }
  }

  List<DateTime> _getCompletedSessionDates() {
    return _sessions
        .map((session) => DateTime.parse(session['date'] as String))
        .toList();
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
        : Column(
            children: [
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
                                TextStyle(color: Colors.black, fontSize: 12.0),
                          ),
                          y: ChartAxisSettingsAxis(
                            frequency: 10.0,
                            max: 100.0,
                            min: 0.0,
                            textStyle:
                                TextStyle(color: Colors.black, fontSize: 12.0),
                          ),
                        ),
                        labelX: (value) => dateLabels[value.toInt() - 1],
                        labelY: (value) => value.toString(),
                      ),
                      ChartLineLayer(
                        items: dataPoints,
                        settings: ChartLineSettings(
                          color: Colors.blue,
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
          );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> completedSessionDates = _getCompletedSessionDates();

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              } else if (value == 'Logout') {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SigninScreen()),
                    (route) => false,
                  );
                });
              } else if (value == 'Personalized Words') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonalizedWordsPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
              const PopupMenuItem(value: 'Logout', child: Text('Logout')),
              const PopupMenuItem(
                  value: 'Personalized Words',
                  child: Text('Personalized Words')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalendarScreen()),
                  );
                },
                child: TableCalendar(
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
                  calendarFormat: CalendarFormat.week,
                  onFormatChanged: (format) {},
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                  locale: 'en_US',
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      if (completedSessionDates.contains(day)) {
                        return Center(
                          child: Stack(
                            children: [
                              Center(
                                child: Text('${day.day}',
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                              ),
                            ],
                          ),
                        );
                      }
                      return Center(
                          child: Text('${day.day}',
                              style: TextStyle(fontSize: 16)));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildCard(
                title: "Real-Time Sessions",
                description: "Engage in live sessions with our tool.",
                context: context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SpeechToTextPage()),
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
                        builder: (context) => DomainSelectionPage()),
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
                        builder: (context) => const DailyChallengePage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showLastFiveSessions = true;
                      });
                    },
                    child: const Text('Last 5 Sessions'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showLastFiveSessions = false;
                      });
                    },
                    child: const Text('All Time Progress'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildLineChart(),
            ],
          ),
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
