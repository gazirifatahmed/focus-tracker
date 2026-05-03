import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/relapse_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ User save
  Future<void> saveUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  // ✅ User get
  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(uid, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // ✅ Relapse add
  Future<void> addRelapse(Relapse relapse) async {
    await _db.collection('relapses').add(relapse.toMap());
  }

  // ✅ User এর সব relapse stream
  Stream<List<Relapse>> getUserRelapses(String userId) {
    return _db
        .collection('relapses')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Relapse.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ✅ Relapse report করার পর user update
  Future<void> updateUserAfterRelapse(
      String uid, DateTime relapseTime, int days) async {
    final userRef = _db.collection('users').doc(uid);
    final userDoc = await userRef.get();
    if (!userDoc.exists) return;

    final data = userDoc.data() as Map<String, dynamic>;
    final currentLongest = data['longestStreak'] ?? 0;
    final newLongest = days > currentLongest ? days : currentLongest;
    final newBadge = _calculateBadge(0); // relapse হলে badge Clown এ reset

    await userRef.update({
      'lastRelapse': relapseTime.toIso8601String(),
      'longestStreak': newLongest,
      'currentBadge': newBadge,
    });
  }

  // ✅ Get Focus — timer reset (createdAt update, lastRelapse null)
  Future<void> updateUserStartDate(String uid, DateTime startDate) async {
    await _db.collection('users').doc(uid).update({
      'createdAt': startDate.toIso8601String(),
      'lastRelapse': FieldValue.delete(), // ✅ null এর বদলে field delete
    });
  }

  // ✅ Badge আলাদাভাবে update (AppProvider থেকে call হয়)
  Future<void> updateUserBadge(String uid, String badge) async {
    await _db.collection('users').doc(uid).update({
      'currentBadge': badge,
    });
  }

  // ✅ Badge calculation
  String _calculateBadge(int days) {
    if (days >= 120) return 'Giga Chad';
    if (days >= 60) return 'Absolute Chad';
    if (days >= 45) return 'Chad';
    if (days >= 30) return 'Sigma';
    if (days >= 15) return 'Advanced';
    if (days >= 7) return 'Average';
    if (days >= 3) return 'Novice';
    if (days >= 1) return 'Noob';
    return 'Clown';
  }

  Future<void> deleteRelapse(String relapseId) async {}
}