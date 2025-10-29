import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mal_provider.dart';

// Sida där användaren kan skapa mål ett nytt dags- eller veckomål

class SkapaMalSida extends StatefulWidget {
  const SkapaMalSida({super.key});

  @override
  State<SkapaMalSida> createState() => _SkapaMalSidaState();
}

class _SkapaMalSidaState extends State<SkapaMalSida> {
  // Lokala tillstånds variabler
  String _malTyp = 'Dagsmål'; // Dagsmål är som standard
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

        // Tillbaka knapp i appbar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () => Navigator.pop(context)
          ),
      ),

      // Huvudinnehåll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rubrik
            const Text("Vad vill du fokusera på?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),

            // Välj måltyp, dagsmål eller veckomål
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

            // Titel på målet
            const Text(
              "Beskriv ditt mål",
            style: TextStyle(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            TextField(
              controller: _malController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Exempel: Gå ut på promenad varje dag",
              ),
            ),

            const SizedBox(height: 16),

            //  Anteckning (valfritt)
            const Text(
              "Anteckning (valfritt)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _anteckningController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Exempel: Kom ihåg att ta med vattenflaska",
              ),
            ),

            const SizedBox(height: 16),

            // Datumväljare för veckomål
            if (_malTyp == 'Veckomål')
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() => _valdDatum = pickedDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey), 
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today), 
                      const SizedBox(width: 8), 
                      Text(_valdDatum == null ? "Välj datum" : "${_valdDatum!.day}/${_valdDatum!.month}/${_valdDatum!.year}"
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Skapa knappen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appBarColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  // Säkerställer att ett mål är ifyllt
                  if (_malController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Skriv in ett mål innan du sparar."),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // Försöker spara målet via provider
                  try {
                    await malProvider.laggTillMal(
                      _malController.text,
                      typ: _malTyp,
                      anteckning: _anteckningController.text,
                      datum: _malTyp == 'Dagsmål'
                          ? DateTime.now()
                          : _valdDatum ?? DateTime.now(),
                    );

                    // Visa bekräftelse till användaren
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
