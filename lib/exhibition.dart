import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'favorites.dart';
import 'highlights.dart';
import 'about.dart';
import 'package:google_fonts/google_fonts.dart';

class ExhibitionPage extends StatefulWidget {
  const ExhibitionPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _ExhibitionPageState createState() => _ExhibitionPageState();
}

class _ExhibitionPageState extends State<ExhibitionPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/exhibitions?fields=exhibition_title,exhibition_start_date,exhibition_end_date,tessitura_string,id,slug,exhibition_narrative,exhibition_abstract,hero_image.*,type,exhibition_status&sort=-exhibition_end_date&limit=1&filter[id][eq]=" +
            id;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
  }

  fitzLogo() {
    return Image.asset('assets/Fitz_logo_white.png', height: 150, width: 150);
  }

  builder(id) {
    return FutureBuilder(
      future: fetchData(http.Client(), id),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final data = jsonDecode(snapshot.data.toString());
        final exhibition = data['data'];
        final SizedBox leading;
        final SizedBox tessitura;
        final startDate =
            DateTime.tryParse(exhibition[0]['exhibition_start_date']);
        final endDate = DateTime.tryParse(exhibition[0]['exhibition_end_date']);
        final tessituraString = exhibition[0]["tessitura_string"];
        final String narrative;
        try {
          if (exhibition[0]['exhibition_narrative'] != null) {
            narrative = exhibition[0]['exhibition_narrative'];
          } else {
            narrative = exhibition[0]['exhibition_abstract'];
          }
        } on TypeError {
          return const SizedBox.shrink();
        }
        _launchURL() async {
          final url = 'https://tickets.museums.cam.ac.uk/overview/' +
              exhibition[0]["tessitura_string"];
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        }

        _launchGeneralURL() async {
          const url =
              'https://tickets.museums.cam.ac.uk/overview/generaladmission';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        }

        try {
          if (tessituraString != null) {
            tessitura = SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _launchURL,
                  child: const Text('Book a ticket'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          } else {
            tessitura = SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _launchGeneralURL,
                  child: const Text('Book general admission'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }
        } on TypeError {
          return const SizedBox.shrink();
        }

        try {
          if (exhibition[0]["hero_image"] == "") {
            leading = SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 350,
              child: Image.asset('assets/Portico.jpg',
                  fit: BoxFit.fill,
                  color: const Color.fromRGBO(117, 117, 117, 0.9),
                  colorBlendMode: BlendMode.modulate),
            );
          } else {
            leading = SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 250,
                child: CircleAvatar(
                  radius: 100.0,
                  backgroundImage: NetworkImage(
                    exhibition[0]['hero_image']['data']['url'],
                  ),
                ));
          }
        } on TypeError {
          return const SizedBox.shrink();
        }
        return Column(
          children: <Widget>[
            Stack(children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 400,
                child: Image.asset("assets/Portico.jpg",
                    fit: BoxFit.fill,
                    color: const Color.fromRGBO(117, 117, 117, 0.9),
                    colorBlendMode: BlendMode.modulate),
              ),

              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 80, 0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      iconSize: 30,
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 40, 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      iconSize: 30,
                      color: Colors.white,
                      icon: const Icon(Icons.favorite),
                      tooltip: "View your selected favourite objects",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FavoritesPage()),
                        );
                      },
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                child:
                    Align(alignment: Alignment.bottomCenter, child: fitzLogo()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 240, 0, 0),
                child:
                    Align(alignment: Alignment.bottomCenter, child: rosette()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 400, 0, 0),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Text(
                            exhibition[0]['exhibition_title'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.libreBaskerville(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 1, 0, 2),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    iconSize: 30,
                    color: Colors.white,
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AboutPage()),
                      );
                    },
                  ),
                )),
            leading,
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          DateFormat.yMMMMd('en_US').format(startDate!) +
                              ' - ' +
                              DateFormat.yMMMMd('en_US').format(endDate!),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.purple)),
                    ),
                  )
                ],
              ),
            ),
            tessitura,
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: MarkdownBody(
                      data: removeAllHtmlTags(narrative),
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            color: Colors.black, fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            explore(),
            pineapple()
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.museum_outlined),
        tooltip: "Go home",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              builder(widget.id),
            ],
          ),
        ),
      ),
    );
  }
}
