import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'highlights.dart';
import 'about.dart';
import 'utilities/fullscreen.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
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
        "https://content.fitz.ms/fitz-website/items/research_projects?fields=*.*.*.*&sort=id&filter[id][eq]=" +
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
          return  Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: SizedBox(
                  height: 100, width: 100,
                  child: Image.asset('assets/rosetteRotate.gif', height: 150, width: 150)
              ),
            ),
          );
        }
        final data = jsonDecode(snapshot.data.toString());
        final gallery = data['data'][0];
        final dynamic leading;
        leading = ImageFullScreenWrapperWidget(
          child: Image.network(
            gallery['hero_image']['data']['url'],
          ),
          dark: true,
        );

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        gallery["title"],
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

            leading,
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: MarkdownBody(
                      data: removeAllHtmlTags(gallery['summary']),
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                            color: Colors.black, fontSize: 16, height: 1.5),
                        blockquote: const TextStyle(
                            color: Colors.red, fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            explore(),
            pineapple(),

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
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Align(
                      alignment: Alignment.bottomCenter, child: fitzLogo()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 240, 0, 0),
                  child: Align(
                      alignment: Alignment.bottomCenter, child: rosette()),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 40, 20),
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
              ]),
              builder(widget.id),
            ],
          ),
        ),
      ),
    );
  }
}
