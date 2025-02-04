import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

Future<void> saveSession({
  required String spokenText,
  required double averageWpm,
  required double withinLimitPercentage,
  required Map<String, int> commonWordCounts,
}) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String sessionId = Uuid().v4();
      DateTime now = DateTime.now();

      Map<String, dynamic> sessionData = {
        'averageWpm': averageWpm,
        'commonWordCounts': commonWordCounts,
        'date': now.toIso8601String(),
        'spokenText': spokenText,
        'withinLimitPercentage': withinLimitPercentage,
      };

      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user.uid)
          .collection('sessions')
          .doc(sessionId)
          .set(sessionData);

      print('Session saved successfully.');
    } else {
      print('No user is signed in.');
    }
  } catch (e) {
    print('Failed to save session: $e');
  }
}
