import 'package:flutter/material.dart';

class ResurserSida extends StatefulWidget {
  const ResurserSida({super.key});

  @override
  State<ResurserSida> createState() => _ResurserSidaState();
}

class _ResurserSidaState extends State<ResurserSida> {
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
  bool _infoExpanded = false;
  bool _videoExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 76, 114),  //Ändrar bakgrunden
      appBar: AppBar(
        title: const Text("Resurser & videor"), //Titel på sidan
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 45, 76, 114),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //"För-info" text sektion-----------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "När språket dröjer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 140, 161, 222)),
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

            //Information och tips sektion-----------------------------------
            Card(
              color: Colors.white,
              elevation: 2,
              child: Column(
                children: [
                  //Knapp för information och tips-----------------------------------
                  InkWell(
                    onTap: () {
                      setState(() {
                        _infoExpanded = !_infoExpanded;
                        // Stäng den andra om denna öppnas
                        if (_infoExpanded) _videoExpanded = false;
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _infoExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Color.fromARGB(255, 40, 77, 122),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //Innehåll för information tabben-----------------------------------
                  if (_infoExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Rubrik
                          const SizedBox(height: 16),
                          Text(
                            "Språket utvecklas i sin egen takt",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 40, 77, 122),
                            ),
                          ),
                          const SizedBox(height: 4),
                          //innehåll
                          Text(
                            "Alla barn börjar kommunicera tidigt genom skrik, leenden och gråt. Så småningom följer joller, babbel och de första orden. Språkutvecklingen följer oftast samma mönster, men takten varierar. Vissa barn pratar tidigt, andra väntar längre innan orden kommer, och en del har svårt med uttal trots att de pratar mycket. Som förälder kan man lätt bli orolig och jämföra med andra barn. Oftast kommer språket ikapp av sig själv, men du kan stötta utvecklingen hemma och ibland kan extra stöd behövas.",
                            style: TextStyle(fontSize: 14)
                          ),


                          const SizedBox(height: 16),
                          //Rubrik
                          Text(
                            "När börjar barn prata?",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 230, 206, 74),
                            ),
                          ),
                          const SizedBox(height: 4),
                          //punktlista
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Barn utvecklar språket i olika takt, och variation är helt normalt. Generellt brukar man säga att:", style: TextStyle(fontSize: 14)),
                              SizedBox(height: 8),
                              _bullet("Vid 1 år - barnet använder enstaka ord"),
                              _bullet("Vid 2 år - barnet sätter ihop två ord"),
                              _bullet("Vid 3 år - familjen förstår vad barnet säger"),
                              _bullet("Vid 4 år - även andra kan förstå barnet"),
                              SizedBox(height: 8),
                              Text("Det viktiga är att barnet försöker kommunicera med ord, gester eller ljud. Om intresset för att prata eller samspela verkar saknas kan det vara bra att söka stöd. ", style: TextStyle(fontSize: 14)),
                              Text("Om ett barn är sent i språkutvecklingen får man ofta träffa en logoped. Logopeden utreder och behandlar olika tal- och språksvårigheter, oavsett orsak. Genom lek och övningar hjälper logopeden barnet att träna uttal, förstå ord och våga använda språket mer aktivt.", style: TextStyle(fontSize: 14)),
                            ],
                          ),


                          const SizedBox(height: 16),
                          //Rubrik
                          Text(
                            "Tips",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 140, 161, 222),
                            ),
                          ),
                          const SizedBox(height: 4),
                          //innehåll
                          Text(
                            "titititititiititititititititit",
                            style: TextStyle(fontSize: 14)
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            //Informationsvideos sektionen -----------------------------------
            Card(
              color: Colors.white,
              elevation: 2,
              child: Column(
                children: [
                  //Knapp för videos -----------------------------------
                  InkWell(
                    onTap: () {
                      setState(() {
                        _videoExpanded = !_videoExpanded;
                        // Stäng den andra om denna öppnas
                        if (_videoExpanded) _infoExpanded = false;
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _videoExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Color.fromARGB(255, 40, 77, 122),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Innehåll för videos tabben-----------------------------------
                  if (_videoExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildVideoItem(
                            "Introduktion till dialogisk läsning",
                            "5:30",
                          ),
                          const SizedBox(height: 16),
                          _buildVideoItem(
                            "Exempel på lässtund",
                            "8:45",
                          ),
                          const SizedBox(height: 16),
                          _buildVideoItem(
                            "Tips för engagerande läsning",
                            "6:15",
                          ),
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

  Widget _buildVideoItem(String title, String duration) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF8CA1DE).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              color: Color(0xFF8CA1DE),
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}