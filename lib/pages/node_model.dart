import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> saveUserData(String name) async {
  final user = _auth.currentUser;
  if (user != null) {
    await _db.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

Future<void> getUserData() async {
  final user = _auth.currentUser;
  if (user != null) {
    DocumentSnapshot doc =
        await _db.collection('users').doc(user.uid).get();
    print(doc.data());
  }
}

//test