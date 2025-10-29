import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mal_provider.dart';

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
    final primaryColor = Theme.of(context).colorScheme.primary; 
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor; 
    final scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: const Text("Skapa nytt mål"),
        backgroundColor: appBarColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
              activeColor: primaryColor,
              onChanged: (value) => setState(() => _malTyp = value!),
            ),
            RadioListTile<String>(
              title: const Text("Veckomål"),
              value: "Veckomål",
              groupValue: _malTyp,
              activeColor: primaryColor,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if (_malController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Skriv in ett mål innan du sparar."),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  try {
                    await malProvider.laggTillMal(
                      _malController.text,
                      typ: _malTyp,
                      anteckning: _anteckningController.text,
                      datum: _malTyp == 'Dagsmål'
                          ? DateTime.now()
                          : _valdDatum ?? DateTime.now(),
                    );

                    // Visa bekräftelse
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Målet har sparats!"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Gå tillbaka till föregående sida
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Kunde inte spara mål: $e"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Skapa mål",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
