import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/session_provider.dart';
import 'betyg.dart';

class SessionerSida extends StatelessWidget {
  const SessionerSida({super.key});

  @override
  Widget build(BuildContext context) {
    final sessioner = Provider.of<SessionProvider>(context).sessioner;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sessioner"),
        backgroundColor: const Color(0xFF8CA1DE),
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
                  "Engagemang: ${s.engagemang}, Kvalitet: ${s.kvalitet}, Uppmärksamhet: ${s.uppmarksamhet}\nAnteckning: ${s.anteckning}"),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF8CA1DE)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BetygSida(readTime: s.lastReadTime, datum: s.datum,),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}