import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/session_provider.dart';
import 'betyg.dart';

//Sida för att visa alla loggade lässessioner
class SessionerSida extends StatelessWidget {
  const SessionerSida({super.key});

  @override
  Widget build(BuildContext context) {

    final sessioner = Provider.of<SessionProvider>(context).sessioner;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sessioner"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessioner.length,
        itemBuilder: (context, index) {
          final s = sessioner[index];
          final displayDate =
              DateFormat('EEEE d MMMM', 'sv_SE').format(DateTime.parse(s.datum));
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(displayDate),
              subtitle: Text(
                  //Visar sammanfattning av betygen och anteckningen
                  "Engagemang: ${s.engagemang}, Kvalitet: ${s.kvalitet}, Uppmärksamhet: ${s.uppmarksamhet}\nAnteckning: ${s.anteckning}"),
              isThreeLine: true,
              //Menyknapp för redigera/radera
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
                  if (value == 'redigera') {
                    // Navigera till betygsida för redigering
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BetygSida(
                          readTime: s.lastReadTime, 
                          datum: s.datum, 
                          sessionId: s.id,
                        ),
                      ),
                    );
                  } else if (value == 'radera') {
                    //Radera
                    // Hitta indexet för den aktuella sessionen
                    final index = sessionProvider.sessioner.indexOf(s);
                    if (index != -1) {
                      await sessionProvider.taBortSession(index);
                    }
                  }
                },
                itemBuilder: (context) => [
                  //Popup-alternativ - Redigera
                  PopupMenuItem(
                    value: 'redigera',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        const Text("Redigera"),
                      ],
                    ),
                  ),
                  //Popup-alternativ - Radera
                  const PopupMenuItem(
                    value: 'radera',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Radera session", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}