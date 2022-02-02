import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import 'utilities/fullscreen.dart';
import 'utilities/icons.dart';
import 'utilities/string_replace.dart';

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
  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/research_projects?fields=*.*.*.*&sort=id&filter[id][eq]=" +
            id;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
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
                  child: errorLoadingRosette()
              ),
            ),
          );
        }
        final data = jsonDecode(snapshot.data.toString());
        final research = data['data'][0];
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  _ResearchProjectTitle(research: research)
                ],
              ),
            ),
            _ResearchImage(research: research),
            _ResearchProjectSummary(research: research),
            pineappleSingle(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingHomeButton(context),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              fitzHomeBanner(context),
              builder(widget.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResearchProjectTitle extends StatelessWidget {
  const _ResearchProjectTitle({Key? key, required this.research}) : super(key: key);
  final dynamic research;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          research["title"],
          textAlign: TextAlign.center,
          style: GoogleFonts.libreBaskerville(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ResearchProjectSummary extends StatelessWidget {
  const _ResearchProjectSummary({Key? key, required this.research})
      : super(key: key);
  final dynamic research;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: MarkdownBody(
              data: removeAllHtmlTags(research['summary']),
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
    );
  }
}

class _ResearchImage extends StatelessWidget{
  const _ResearchImage({Key? key, required this.research})
      : super(key: key);
  final dynamic research;

  @override
  Widget build(BuildContext context) {
    return ImageFullScreenWrapperWidget(
      child: Image.network(
        research['hero_image']['data']['url'],
      ),
      dark: true,
    );
  }
}