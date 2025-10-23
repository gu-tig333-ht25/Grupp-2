import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mal_provider.dart';
import 'skapa_mal_sida.dart';

// --- Filtreringstyper ---
enum Filtrering { alla, klara, ejKlara }

class MalSida extends StatelessWidget {
  const MalSida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        title: const Text("Dina mål"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 'alla') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const FiltreradMalSida(filtrering: Filtrering.alla),
                  ),
                );
              } else if (value == 'klara') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const FiltreradMalSida(filtrering: Filtrering.klara),
                  ),
                );
              } else if (value == 'ejklara') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const FiltreradMalSida(filtrering: Filtrering.ejKlara),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'alla',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text("Alla mål"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'klara',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Avklarade mål"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ejklara',
                child: Row(
                  children: [
                    Icon(Icons.radio_button_unchecked, color: Colors.orange),
                    SizedBox(width: 8),
                    Text("Ej avklarade mål"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const MalListaView(filtrering: Filtrering.alla),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8CA1DE),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SkapaMalSida()),
          );
        },
        label: const Text("Lägg till mål"),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class FiltreradMalSida extends StatelessWidget {
  final Filtrering filtrering;
  const FiltreradMalSida({super.key, required this.filtrering});

  String _getTitel() {
    switch (filtrering) {
      case Filtrering.klara:
        return "Avklarade mål";
      case Filtrering.ejKlara:
        return "Ej avklarade mål";
      default:
        return "Alla mål";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        title: Text(_getTitel()),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: MalListaView(filtrering: filtrering),
    );
  }
}

class MalListaView extends StatelessWidget {
  final Filtrering filtrering;
  const MalListaView({super.key, required this.filtrering});

  @override
  Widget build(BuildContext context) {
    return Consumer<MalProvider>(
      builder: (context, malProvider, child) {
        final allaMal = malProvider.malLista;

        // 🔍 Filtrera målen efter status
        final filtrerad = switch (filtrering) {
          Filtrering.klara => allaMal.where((m) => m.klar).toList(),
          Filtrering.ejKlara => allaMal.where((m) => !m.klar).toList(),
          _ => allaMal,
        };

        final dagsMal = filtrerad.where((m) => m.typ == 'Dagsmål').toList();
        final veckMal = filtrerad.where((m) => m.typ == 'Veckomål').toList();

        // Sortera
        dagsMal.sort((a, b) =>
            (a.datum ?? DateTime.now()).compareTo(b.datum ?? DateTime.now()));
        veckMal.sort((a, b) =>
            (a.datum ?? DateTime.now()).compareTo(b.datum ?? DateTime.now()));

        final grupperadeVeckor = <int, List<Mal>>{};
        for (var mal in veckMal) {
          grupperadeVeckor.putIfAbsent(mal.vecka, () => []).add(mal);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Dagens mål",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (dagsMal.isEmpty)
              const Text("Inga dagsmål", style: TextStyle(color: Colors.grey))
            else
              ...dagsMal.map(
                (mal) => GoalItem(
                  mal: mal,
                  index: malProvider.malLista.indexOf(mal),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              "Veckomål",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (grupperadeVeckor.isEmpty)
              const Text("Inga veckomål", style: TextStyle(color: Colors.grey))
            else
              ...grupperadeVeckor.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Vecka ${entry.key}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF8CA1DE))),
                    const SizedBox(height: 4),
                    ...entry.value.map((mal) => GoalItem(
                          mal: mal,
                          index: malProvider.malLista.indexOf(mal),
                        )),
                    const SizedBox(height: 12),
                  ],
                );
              }),
          ],
        );
      },
    );
  }
}

class GoalItem extends StatelessWidget {
  final Mal mal;
  final int index;

  const GoalItem({super.key, required this.mal, required this.index});

  @override
  Widget build(BuildContext context) {
    final malProvider = Provider.of<MalProvider>(context, listen: false);

    String formatDatum(DateTime? d) {
      if (d == null) return '';
      return "${d.day}/${d.month}/${d.year}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: mal.klar,
          activeColor: const Color(0xFF8CA1DE),
          onChanged: (_) {
            // ✅ Uppdatera status
            malProvider.toggleKlar(index);
            // 🔁 Detta triggar ombyggnad av UI och gör att målet försvinner
            malProvider.notifyListeners();
          },
        ),
        title: Text(
          mal.titel,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: mal.klar ? Colors.grey : Colors.black,
            decoration: mal.klar ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mal.anteckning.isNotEmpty)
              Text(mal.anteckning, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            if (mal.datum != null)
              Text(
                mal.typ == 'Dagsmål'
                    ? "Datum: ${formatDatum(mal.datum)}"
                    : "Vecka ${mal.vecka}, ${mal.datum!.year} (${formatDatum(mal.datum)})",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'radera') {
              malProvider.taBortMal(index);
              malProvider.notifyListeners();
            } else if (value == 'redigera') {
              _visaRedigeringsDialog(context, malProvider, mal, index);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'redigera',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Redigera mål"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'radera',
              child: Text("Radera mål",
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  void _visaRedigeringsDialog(
      BuildContext context, MalProvider provider, Mal mal, int index) {
    final titelController = TextEditingController(text: mal.titel);
    final anteckningController = TextEditingController(text: mal.anteckning);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Redigera mål"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titelController,
              decoration: const InputDecoration(labelText: "Titel"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: anteckningController,
              decoration: const InputDecoration(labelText: "Anteckning"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Avbryt"),
          ),
          TextButton(
            onPressed: () {
              mal.titel = titelController.text;
              mal.anteckning = anteckningController.text;
              provider.notifyListeners();
              Navigator.pop(context);
            },
            child: const Text("Spara",
                style: TextStyle(color: Color(0xFF8CA1DE))),
          ),
        ],
      ),
    );
  }
}
