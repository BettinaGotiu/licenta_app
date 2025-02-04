import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SessionService {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> fetchSessionData() async {
    List<Map<String, dynamic>> sessions = [];
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .collection('sessions')
          .orderBy('date')
          .get();

      await Future.delayed(const Duration(seconds: 0)); // Artificial delay

      sessions = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    }
    return sessions;
  }

  Future<void> deleteSession(String sessionId) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .collection('sessions')
          .doc(sessionId)
          .delete();
    }
  }
}
