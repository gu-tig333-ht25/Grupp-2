import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mal_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

Future<void> saveGoalToFirestore({
  required String title,
  required String type,
  String? note,
  DateTime? date,
}) async {
  final user = _auth.currentUser;
  if (user == null) return;

  await _db
      .collection('users')
      .doc(user.uid)
      .collection('goals')
      .add({
        'title': title,
        'type': type,
        'note': note ?? '',
        'date': date != null ? Timestamp.fromDate(date) : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
}

class SkapaMalSida extends StatefulWidget {
  const SkapaMalSida({super.key});

  @override
  State<SkapaMalSida> createState() => _SkapaMalSidaState();
}

class _SkapaMalSidaState extends State<SkapaMalSida> {
  String _malTyp = 'Dagsmål';
  final TextEditingController _malController = TextEditingController();
  final TextEditingController _anteckningController = TextEditingController();
  DateTime? _valdDatum;

  @override
  Widget build(BuildContext context) {
    final malProvider = Provider.of<MalProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        title: const Text("Skapa nytt mål"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Vad vill du fokusera på?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text("Dagsmål"),
              value: "Dagsmål",
              groupValue: _malTyp,
              onChanged: (value) => setState(() => _malTyp = value!),
            ),
            RadioListTile<String>(
              title: const Text("Veckomål"),
              value: "Veckomål",
              groupValue: _malTyp,
              onChanged: (value) => setState(() => _malTyp = value!),
            ),
            const SizedBox(height: 16),
            const Text("Beskriv ditt mål", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _malController, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text("Anteckning (valfritt)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(controller: _anteckningController, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            if (_malTyp == 'Veckomål')
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) setState(() => _valdDatum = pickedDate);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [const Icon(Icons.calendar_today), const SizedBox(width: 8), Text(_valdDatum == null ? "Välj datum" : "${_valdDatum!.day}/${_valdDatum!.month}/${_valdDatum!.year}")]),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8CA1DE)),
                onPressed: () async{
                  if (_malController.text.isNotEmpty) {
                    final title = _malController.text;
                    final note = _anteckningController.text;
                    final type = _malTyp;
                    final date = _malTyp == 'Dagsmål' ? DateTime.now() : _valdDatum;
                    
                    malProvider.laggTillMal(
                      _malController.text,
                      typ: _malTyp,
                      anteckning: _anteckningController.text,
                      datum: _malTyp == 'Dagsmål' ? DateTime.now() : _valdDatum,
                    );
                    await saveGoalToFirestore(
                      title: title,
                      type: type,
                      note: note,
                      date: date,
                    );
                  Navigator.pop(context);
                  }
                },
                child: const Text("Skapa mål", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
