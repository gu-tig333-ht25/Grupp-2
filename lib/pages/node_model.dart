import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Instanser för att interagera med Firebase
final FirebaseFirestore _db = FirebaseFirestore.instance; //databas
final FirebaseAuth _auth = FirebaseAuth.instance; //Autentisering

//Spara användarinfo - sparar grundläggande användarinfo i Firestore efter registrering
Future<void> saveUserData(String name) async {
  final user = _auth.currentUser;
  //Kontrollerar att en användare är inloggad/registrerad
  if (user != null) {
    //Sätter dokumentet i 'users/{uid}' samlingen
    await _db.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(), // Tidsstämpel när kontot skapades
    });
  }
}

//HÄmtar användarinfo från firestore och skriver ut den (för debug)
Future<void> getUserData() async {
  final user = _auth.currentUser;
  if (user != null) { //Hämtar dokument
    DocumentSnapshot doc =
        await _db.collection('users').doc(user.uid).get();
    print(doc.data()); //Skriver ut datan
  }
}