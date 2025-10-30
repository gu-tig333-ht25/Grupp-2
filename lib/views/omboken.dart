import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/* Sida som visar information om en barnbok ex 'Knacka på'
Här finns inbäddat youtubeklipp och exempel på PEER metoder för högläsning */

class OmBokenSida extends StatefulWidget {
  const OmBokenSida({super.key});

  @override
  State<OmBokenSida> createState() => _OmBokenSidaState();
}

class _OmBokenSidaState extends State<OmBokenSida> {
  //YouTube-kontrollern 
  late YoutubePlayerController _youtubeController;

  // YouTube video ID
  final String _videoId = '8cJZ9L29uLM'; 

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  // Frigör resurserna när sidan stängs
  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  //En hjälp widget för PEER-frågor, en mall kan man nästan säga 
  Widget _buildPeerSection(String title, String description, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(4)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titel tex P = promta
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Beskrivande tex / exempel
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 252, 252, 252),  //Ändrar bakgrunden
      appBar: AppBar(
        title: const Text("Om boken"), // Titeln i appbaren
        centerTitle: true,
        backgroundColor: 
          Color.fromARGB(255, 45, 76, 114), // Ändrar färgen på appbaren
        foregroundColor: 
          Color.fromARGB(255, 252, 252, 252), // Ändrar färgen på texten i appbaren
      ),

      // Huvudinnehåll, skollbar för att få plats med all text
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            //Titeln ovanför youtube klippet 
            const Text(
              "Exempelbok: Knacka på",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 45, 76, 114)), 
            ),
            const SizedBox(height: 16),

            // Youtube klippet inbäddat
            YoutubePlayer(
              controller: _youtubeController,
              showVideoProgressIndicator: true,
            ),
            
            const SizedBox(height: 16),

            //Texten under youtube klippet, förklaring om boken
            const Text(
              "Om klippet:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 45, 76, 114)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Boken handlar om vad som kan dölja sig bakom stängda dörrar och uppmuntrar barn att delta aktivt i berättelsen genom att knacka på dörrarna och gissa vem som bor bakom dem. Den finns även som app och har tryckts i många upplagor, vilket gör den till en klassiker för små barn.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            
            const SizedBox(height: 24),
            
            //exempel på användning av PEER metoden 
            const Text(
              "PEER-stegen och exempel på frågor:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 45, 76, 114)),
            ),
            const SizedBox(height: 10),

            // Exempel på PEER steg
            _buildPeerSection(
              "P: Prompta (Be barnet svara)",
              "Uppmana barnet till att svara på en fråga relaterad till boken eller sidan, exempelvis 'Vem tror du bor bakom den röda dörren?'",
              Color.fromARGB(255, 45, 76, 114),
            ),
            _buildPeerSection(
              "E: Utvärdera (Beröm/erkänn barnets svar)",
              "Exempel: 'Jättebra! Det stämmer att det är kaniner!', 'Ja, du gissade rätt!'",
              Color.fromARGB(255, 230, 206, 74),
            ),
            _buildPeerSection(
              "E: Expandera (Bygg ut barnets svar)",
              "Exempel: 'Det är sju kaniner som äter middag. De gillar nog morötter, precis som du!'",
              Color.fromARGB(255, 140, 161, 222),
            ),
            _buildPeerSection(
              "R: Repetera (Repetera den expanderade frasen)",
              "Exempel: 'Kan du säga 'Det är sju kaniner som äter middag'?",
              Color.fromARGB(255, 25, 42, 62),
            ),

            // Avslutande text
            const SizedBox(height: 20),
            const Text(
              "Genom att följa PEER-stegen hjälper du ditt barn att utveckla sitt ordförråd och sin narrativa förmåga.",
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}