import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _sessionDates = {}; // Using Set for quick lookup
  bool _isLoading = true;

  // New color palette
  final Color primaryColor = Color(0xFF3539AC); // rgba(53,37,172,255)
  final Color secondaryColor = Color(0xFF11BDE3); // rgba(17,189,227,255)
  final Color accentColor = Color(0xFFFF3926); // rgba(255,57,38,255)
  final Color backgroundColor = Color(0xFFEFF3FE); // rgba(239,243,254,255)
  final Color textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _fetchSessionDates();
  }

  Future<void> _fetchSessionDates() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user.uid)
          .collection('sessions')
          .orderBy('date')
          .get();

      setState(() {
        _sessionDates = snapshot.docs.map((doc) {
          DateTime date = DateTime.parse(doc['date']);
          return DateTime(date.year, date.month, date.day);
        }).toSet();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isSessionDate(DateTime date) {
    return _sessionDates.contains(DateTime(date.year, date.month, date.day));
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
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0, right: 70),
                  child: Text(
                    "Streak Calendar",
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
      ),
      body: FutureBuilder(
        future: _fetchSessionDates(),
        builder: (context, snapshot) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
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
                child: TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                    _fetchSessionDates();
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      if (_isSessionDate(date)) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color:
                                secondaryColor, // Use secondary color for session days
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                    todayBuilder: (context, date, _) {
                      if (_isSessionDate(date)) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color:
                                secondaryColor, // Use secondary color for today if session exists
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                      return null; // Removes default purple highlight if no session today
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
