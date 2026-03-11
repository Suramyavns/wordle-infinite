import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> getStatsFromFirestore(String userId) {
  return FirebaseFirestore.instance
      .collection('stats')
      .where('userId', isEqualTo: userId)
      .snapshots();
}

Future<void> addStatsToFirestore(String userId, int tries, bool isWin) {
  return FirebaseFirestore.instance.collection('stats').add({
    'userId': userId,
    'tries': tries,
    'wasGuessed': isWin,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
