import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> findUserById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await _firestore.collection('users').doc(id).get();

    if (!userSnapshot.exists) {
      return null;
    }

    return userSnapshot.data();
  }
}
