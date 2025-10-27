//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'session_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 

class BetygSida extends StatefulWidget {
  final String? readTime; // Lästid från timer
  const BetygSida({super.key, this.readTime});

  @override
  State<BetygSida> createState() => _BetygSidaState();
}

class _BetygSidaState extends State<BetygSida> {
  int engagemang = 0;
  int kvalitet = 0;
  int uppmarksamhet = 0;
  TextEditingController anteckningController = TextEditingController();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final session = Provider.of<SessionProvider>(context, listen: false)
        .getSessionForDate(today);

    if (session != null) {
      engagemang = session.engagemang;
      kvalitet = session.kvalitet;
      uppmarksamhet = session.uppmarksamhet;
      anteckningController.text = session.anteckning;
    }
  }

  Future<void> saveSessionToFirestore(Session session) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db
        .collection('users')
        .doc(user.uid)
        .collection('sessions')
        .doc(session.datum)
        .set({
          'engagemang': session.engagemang,
          'kvalitet': session.kvalitet,
          'uppmarksamhet': session.uppmarksamhet,
          'anteckning': session.anteckning,
          'lastReadTime': session.lastReadTime,
          'timestamp': FieldValue.serverTimestamp(),
        });
    }
  }

  Widget starRating(String label, int value, void Function(int) onChanged) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label)),
        ...List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < value ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () => onChanged(index + 1),
          );
        })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Betygsätt dagens session"),
        backgroundColor: const Color(0xFF8CA1DE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lästid idag: ${widget.readTime ?? '00:00'}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              starRating("Engagemang", engagemang, (v) {
                setState(() => engagemang = v);
              }),
              starRating("Kvalitet", kvalitet, (v) {
                setState(() => kvalitet = v);
              }),
              starRating("Uppmärksamhet", uppmarksamhet, (v) {
                setState(() => uppmarksamhet = v);
              }),
              const SizedBox(height: 16),
              TextField(
                controller: anteckningController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Anteckning (frivillig)',
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  // ----- // 
                  onPressed: () async {
                    final session = Session(
                      datum: today,
                      engagemang: engagemang,
                      kvalitet: kvalitet,
                      uppmarksamhet: uppmarksamhet,
                      anteckning: anteckningController.text,
                      lastReadTime: widget.readTime ?? '00:00',
                    );

                    Provider.of<SessionProvider>(context, listen: false)
                        .addOrUpdateSession(session);

                    await saveSessionToFirestore(session);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session sparad i firebase'),
                        ),
                      );
                    }

                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8CA1DE),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: const Text("Spara", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}