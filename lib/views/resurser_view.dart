import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/* Sida som innehåller resurser, informationsvideor och PEER sekvenser
Användaren kan expandera sektioner för att läsa mer eller titta på klipp */

class ResurserSida extends StatefulWidget {
  const ResurserSida({super.key});

  @override
  State<ResurserSida> createState() => _ResurserSidaState();
}

class _ResurserSidaState extends State<ResurserSida> {
  //Deklarerar kontrollanterna för youtube videorna
  late YoutubePlayerController _controller1;
  late YoutubePlayerController _controller2;
  late YoutubePlayerController _controller3;

  //Initialisera kontrollanterna i initState()
  @override
  void initState() {
    super.initState();
    _controller1 = YoutubePlayerController(
      initialVideoId: 'tpb_w4qXrB8', // Video 1 ID: Introduktion till dialogisk läsning
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _controller2 = YoutubePlayerController(
      initialVideoId: '-708YcjfVh4', // Video 2 ID: Exempel på lässtund
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
    _controller3 = YoutubePlayerController(
      initialVideoId: 'F2Y6hg4Twi4', // Video 3 ID: Tips för dialogisk läsning
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
  }

  //Frigör resurserna i dispose
  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }
  
  // Hjälpmetod som visar punktlisor med '•'
  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 20)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
  
  // Variabler för att hålla koll på vilka sektioner som är expanderade
  bool _infoExpanded = false;
  bool _videoExpanded = false;
  bool _peerExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 76, 114), // Ändrar bakgrunden
      appBar: AppBar(
        title: const Text("Resurser & videor"), // Titel på sidan
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 76, 114),
        foregroundColor: Colors.white,
      ),

      // Huvudinnehållet
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // "För-info" text sektion
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "När språket dröjer",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 254)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Sen språkutveckling kan ibland tyda på att barnet behöver extra stöd, men det går ofta att hjälpa med insatser från BVC, logoped och dig som förälder.",
                    style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 251, 250, 250)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Här får du veta generell information och får tips på hur du kan stötta språkutvecklingen hemma",
                    style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 250, 250, 250)),
                  ),
                ],
              ),
            ),

            // Information och tips sektion
            Card(
              color: Colors.white,
              elevation: 2,
              child: Column(
                children: [
                  // Knapp för expandera sektionen information och tips
                  InkWell(
                    onTap: () {
                      setState(() {
                        _infoExpanded = !_infoExpanded;
                        if (_infoExpanded) {
                          _videoExpanded = false;
                          _peerExpanded = false;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(12),
                          bottom: Radius.circular(_infoExpanded ? 0 : 12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Color.fromARGB(255, 40, 77, 122)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Information och tips",
                              style: TextStyle(
                                color: Color.fromARGB(255, 40, 77, 122),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _infoExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color.fromARGB(255, 40, 77, 122),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Innehåll för information tabben när den expanderas
                  if (_infoExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            "Språket utvecklas i sin egen takt",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 40, 77, 122),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Innehåll
                          const Text(
                            "Alla barn börjar kommunicera tidigt genom skrik, leenden och gråt. Så småningom följer joller, babbel och de första orden. Språkutvecklingen följer oftast samma mönster, men takten varierar. Vissa barn pratar tidigt, andra väntar längre innan orden kommer, och en del har svårt med uttal trots att de pratar mycket. Som förälder kan man lätt bli orolig och jämföra med andra barn. Oftast kommer språket ikapp av sig själv, men du kan stötta utvecklingen hemma och ibland kan extra stöd behövas.",
                            style: TextStyle(fontSize: 14)
                          ),


                          const SizedBox(height: 16),
                          const Text(
                            "När börjar barn prata?",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 230, 206, 74),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Barn utvecklar språket i olika takt, och variation är helt normalt. Generellt brukar man säga att:", style: TextStyle(fontSize: 14)),
                              const SizedBox(height: 8),
                              _bullet("Vid 1 år - barnet använder enstaka ord"),
                              _bullet("Vid 2 år - barnet sätter ihop två ord"),
                              _bullet("Vid 3 år - familjen förstår vad barnet säger"),
                              _bullet("Vid 4 år - även andra kan förstå barnet"),
                              const SizedBox(height: 8),
                              const Text("Det viktiga är att barnet försöker kommunicera med ord, gester eller ljud. Om intresset för att prata eller samspela verkar saknas kan det vara bra att söka stöd. ", style: TextStyle(fontSize: 14)),
                              const Text("Om ett barn är sent i språkutvecklingen får man ofta träffa en logoped. Logopeden utreder och behandlar olika tal- och språksvårigheter, oavsett orsak. Genom lek och övningar hjälper logopeden barnet att träna uttal, förstå ord och våga använda språket mer aktivt.", style: TextStyle(fontSize: 14)),
                            ],
                          ),


                          const SizedBox(height: 16),
                          const Text(
                            "Tips för att stötta ditt barns språkutveckling",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 140, 161, 222),
                            ),
                          ),
                          const SizedBox(height: 4),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _bullet(" Prata och lyssna mycket\nKommunicera med ditt barn från första dagen. All kontakt, ord, gester eller gråt är språkträning. Visa intresse, svara, och bekräfta det barnet uttrycker."),
                              _bullet(" Sätt ord på vardagen\nBerätta vad ni gör: “Nu tar vi på byxorna” eller “Titta, en röd bil!”. Använd korta, tydliga meningar och ge barnet tid att reagera."),
                              _bullet(" Lek och ha roligt\nLeken är nyckeln till lärande. Följ barnets intresse, turas om, lyssna och sätt ord på det ni gör. Språket utvecklas bäst när det är roligt."),
                              _bullet(" Fokusera på det positiva\nRätta inte barnets uttal hela tiden. Om barnet säger “tatt”, svara bekräftande: “Ja, en katt!”. På så sätt lär sig barnet utan att tappa lusten att prata."),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),


            // Informationsvideos sektionen
            Card(
              color: Colors.white,
              elevation: 2,
              child: Column(
                children: [
                  //Knapp för videos
                  InkWell(
                    onTap: () {
                      setState(() {
                        _videoExpanded = !_videoExpanded;
                        if (_videoExpanded) {
                          _infoExpanded = false;
                          _peerExpanded = false;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 244, 245, 246),
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(12),
                          bottom: Radius.circular(_videoExpanded ? 0 : 12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.video_library, color: Color.fromARGB(255, 40, 77, 122)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Informationsvideos",
                              style: TextStyle(
                                color: Color.fromARGB(255, 40, 77, 122),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _videoExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color.fromARGB(255, 40, 77, 122),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Innehåll för videos tabben
                  if (_videoExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Video 1 titel och spelare
                          const Text("Introduktion till dialogisk läsning", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          YoutubePlayer(
                            controller: _controller1, //Controller 1 används här
                            showVideoProgressIndicator: true, 
                          ),
                          const SizedBox(height: 24),

                          // Video 2 titel och spelare
                          const Text("Exempel på lässtund", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          YoutubePlayer(
                            controller: _controller2, //Controller 2 används här
                            showVideoProgressIndicator: true,
                          ),
                          const SizedBox(height: 24),

                          // Video 3 titel och spelare
                          const Text("Tips för dialogisk läsning", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          YoutubePlayer(
                            controller: _controller3, //Controller 3 används här
                            showVideoProgressIndicator: true,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PEER-sekvens sektion
            Card(
              color: Colors.white,
              elevation: 2,
              child: Column(
                children: [
                  // Knapp för PEERsekvens
                  InkWell(
                    onTap: () {
                      setState(() {
                        _peerExpanded = !_peerExpanded;
                        if (_peerExpanded) {
                          _infoExpanded = false;
                          _videoExpanded = false;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 244, 245, 246),
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(12),
                          bottom: Radius.circular(_peerExpanded ? 0 : 12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups, color: Color.fromARGB(255, 40, 77, 122)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "PEER sekvens",
                              style: TextStyle(
                                color: Color.fromARGB(255, 40, 77, 122),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _peerExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color.fromARGB(255, 40, 77, 122),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Innehåll för PEER sekvens
                  if (_peerExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            "Vad är PEER-sekvensen?",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 40, 77, 122),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Innehåll
                          const Text(
                            "PEER är en kort samtalssekvens mellan barnet och den vuxna. Den används när man delar en bok tillsammans, efter att ni redan har läst igenom boken minst en gång. Metoden kan användas på nästan varje sida i boken.",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Målet är enkelt: att låta barnet bli berättaren. Med tiden läser den vuxna mindre, och barnet pratar mer. Lyssna på barnet och följ det som barnet berättar.",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          _bullet("P - Prompt: Uppmuntra barnet till att säga något om boken eller sidan"),
                          _bullet("E - Evaluate: Utvärdera barnets svar."),
                          _bullet("E - Expand: Utveckla barnets svar genom att omformulera eller lägga till lite mer information."),
                          _bullet("R - Repeat: Upprepa barnets svar, och låt barnet upprepa den utvecklade formen."),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}