import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mal_provider.dart';

class MalSida extends StatelessWidget {
  const MalSida({super.key});

  @override
  Widget build(BuildContext context) {
    final malProvider = Provider.of<MalProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mål"),
        centerTitle: true,
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📝 Dina Mål",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: malProvider.malLista.isEmpty
                  ? const Center(
                      child: Text(
                        "Inga mål ännu. Klicka på knappen nedan för att lägga till.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: malProvider.malLista.length,
                      itemBuilder: (context, index) {
                        return GoalItem(
                          title: malProvider.malLista[index],
                          onDelete: () => malProvider.taBortMal(index),
                          onEdit: () async {
                            final nyttMal = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NyttMalSida(
                                  initialText: malProvider.malLista[index],
                                ),
                              ),
                            );
                            if (nyttMal != null && nyttMal.isNotEmpty) {
                              malProvider.redigeraMal(index, nyttMal);
                            }
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8CA1DE),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Lägg till eget mål", style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  final nyttMal = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NyttMalSida()),
                  );
                  if (nyttMal != null && nyttMal.isNotEmpty) {
                    malProvider.laggTillMal(nyttMal);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalItem extends StatefulWidget {
  final String title;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const GoalItem({
    super.key,
    required this.title,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<GoalItem> createState() => _GoalItemState();
}

class _GoalItemState extends State<GoalItem> {
  bool _uppnatt = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: _uppnatt,
          onChanged: (value) {
            setState(() {
              _uppnatt = value ?? false;
            });
          },
          activeColor: const Color(0xFF8CA1DE),
        ),
        title: Text(widget.title),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              widget.onEdit();
            } else if (value == 'delete') {
              widget.onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Redigera')),
            const PopupMenuItem(value: 'delete', child: Text('Ta bort')),
          ],
        ),
      ),
    );
  }
}

class NyttMalSida extends StatefulWidget {
  final String? initialText;
  const NyttMalSida({super.key, this.initialText});

  @override
  State<NyttMalSida> createState() => _NyttMalSidaState();
}

class _NyttMalSidaState extends State<NyttMalSida> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialText == null ? "Nytt mål" : "Redigera mål"),
        backgroundColor: const Color(0xFF8CA1DE),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Skriv in ditt mål:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CA1DE),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text("Spara mål", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
