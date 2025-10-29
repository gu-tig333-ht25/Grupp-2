import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mal_provider.dart';
import '../views/skapa_mal_sida.dart';

// --- Filtreringstyper ---
enum Filtrering { alla, klara, ejKlara }

class MalSida extends StatefulWidget {
  const MalSida({super.key});

  @override
  State<MalSida> createState() => _MalSidaState();
}

class _MalSidaState extends State<MalSida> {
  Filtrering _valdFiltrering = Filtrering.alla;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<MalProvider>(context, listen: false).loadGoalsFromFirestore();
  });
}


  String _getTitel() {
    switch (_valdFiltrering) {
      case Filtrering.klara:
        return "Avklarade mål";
      case Filtrering.ejKlara:
        return "Ej avklarade mål";
      default:
        return "Dina mål";
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary; 
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor; 
    final scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(_getTitel()), 
        backgroundColor: appBarColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        
        // --- ÄNDRING 1: Lägg tillbaks tillbakapilen manuellt i leading ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),

        // --- ÄNDRING 2: Flytta Drawer-ikonen till actions och öppna den manuellt ---
        actions: [
          Builder( // Använd Builder för att få en context som är barn till Scaffold
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Öppnar sidomenyn
                },
              );
            }
          ),
        ],
      ),
      
      // Drawer (sidomenyn) ligger kvar som filtreringsmekanism
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: appBarColor),
              child: const Text(
                'Filtrera mål',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Alla mål"),
              selected: _valdFiltrering == Filtrering.alla,
              selectedTileColor: primaryColor.withAlpha(26),
              onTap: () {
                setState(() => _valdFiltrering = Filtrering.alla);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text("Avklarade mål"),
              selected: _valdFiltrering == Filtrering.klara,
              selectedTileColor: primaryColor.withAlpha(26),
              onTap: () {
                setState(() => _valdFiltrering = Filtrering.klara);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.radio_button_unchecked, color: Colors.orange),
              title: const Text("Ej avklarade mål"),
              selected: _valdFiltrering == Filtrering.ejKlara,
              selectedTileColor: primaryColor.withAlpha(26),
              onTap: () {
                setState(() => _valdFiltrering = Filtrering.ejKlara);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      // Skicka det aktuella filtret till MalListaView
      body: MalListaView(filtrering: _valdFiltrering),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: appBarColor,
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

// ... (MalListaView och GoalItem förblir oförändrade nedan) ...

class MalListaView extends StatefulWidget {
  final Filtrering filtrering;
  const MalListaView({super.key, required this.filtrering});

  @override
  State<MalListaView> createState() => _MalListaViewState();
}

class _MalListaViewState extends State<MalListaView> {
  @override
  void initState() {
    super.initState();
    final malProvider = Provider.of<MalProvider>(context, listen: false);
    malProvider.loadGoalsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final malProvider = Provider.of<MalProvider>(context); 
    final allaMal = malProvider.malLista;
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;

    final filtrerad = switch (widget.filtrering) {
      Filtrering.klara => allaMal.where((m) => m.klar).toList(),
      Filtrering.ejKlara => allaMal.where((m) => !m.klar).toList(),
      _ => allaMal,
    };

    final dagsMal = filtrerad.where((m) => m.typ == 'Dagsmål').toList();
    final veckMal = filtrerad.where((m) => m.typ == 'Veckomål').toList();

    dagsMal.sort((a, b) =>
        (a.datum ?? DateTime.now()).compareTo(b.datum ?? DateTime.now()));
    veckMal.sort((a, b) =>
        (a.datum ?? DateTime.now()).compareTo(b.datum ?? DateTime.now()));

    final grupperadeVeckor = <int, List<dynamic>>{};
    for (var mal in veckMal) {
      final vecka = (mal.vecka as int?) ?? 0; 
      grupperadeVeckor.putIfAbsent(vecka, () => []).add(mal);
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: appBarColor)),
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
  }
}

class GoalItem extends StatelessWidget {
  final dynamic mal;
  final int index;

  const GoalItem({super.key, required this.mal, required this.index});

  @override
  Widget build(BuildContext context) {
    final malProvider = Provider.of<MalProvider>(context, listen: false); 
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;

    String formatDatum(DateTime? d) {
      if (d == null) return '';
      return "${d.day}/${d.month}/${d.year}";
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: mal.klar,
          activeColor: appBarColor,
          onChanged: (_) => malProvider.toggleKlar(index), 
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
            } else if (value == 'redigera') {
              _visaRedigeringsDialog(context, malProvider, mal, index, appBarColor);
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
    BuildContext context, MalProvider provider, dynamic mal, int index, Color? appBarColor) {
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
              provider.uppdateraMalDetaljer(
                index,
                titelController.text,
                anteckningController.text,
              );
              Navigator.pop(context);
            },
            child: Text("Spara",
                style: TextStyle(color: appBarColor)),
          ),
        ],
      ),
    );
  }
}