import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late User? user;
  List<Map<String, dynamic>> _sessions = [];

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
        _sessions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sessions.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (context, index) {
                  final session = _sessions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      title: Text(
                        'Session ${index + 1}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Date: ${session['date']}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SessionDetailScreen(session: session),
                            ),
                          );
                        },
                        child: const Text("Access"),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class SessionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> session;

  const SessionDetailScreen({Key? key, required this.session})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${session['date']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Average WPM: ${session['averageWpm']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Within Limit Percentage: ${session['withinLimitPercentage']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Spoken Text: ${session['spokenText']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Common Word Counts: ${session['commonWordCounts']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
