import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import 'utilities/fullscreen.dart';
import 'utilities/string_replace.dart';
import 'utilities/icons.dart';


class HighlightPage extends StatefulWidget {
  const HighlightPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _HighlightPageState createState() => _HighlightPageState();
}

class _HighlightPageState extends State<HighlightPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/pharos?fields=*.*.*.*&limit=1&filter[id][eq]=" +
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
          return Align(alignment: Alignment.center, child: errorLoadingRosette());
        }
        final data = jsonDecode(snapshot.data.toString());
        final pharos = data['data'][0];
        return Column(
          children: <Widget>[
            _ObjectTitle(pharos: pharos),
            _ObjectMaker(pharos: pharos),
            _Image(pharos: pharos),
            _ObjectDescription(pharos: pharos),
            _Chip(pharos: pharos),
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
              Stack(children: <Widget>[
                portico(context),
                backIcon(context),
                aboutIcon(context),
                homeLogo(),
                homeRosette(),
              ]),
              builder(widget.id),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({Key? key, required this.pharos}) : super(key: key);
  final dynamic pharos;
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(pharos["period_assigned"]),
    );
  }
}

class _ObjectTitle extends StatelessWidget {
  const _ObjectTitle({Key? key, required this.pharos}) : super(key: key);
  final dynamic pharos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                pharos["title"],
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                  fontSize: 20
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ObjectDescription extends StatelessWidget {
  const _ObjectDescription({Key? key, required this.pharos}) : super(key: key);
  final dynamic pharos;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: MarkdownBody(
              data: removeAllHtmlTags(pharos['description']),
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                    color: Colors.black, fontSize: 18, height: 1.5
                ),
                blockquote: const TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                    height: 1.5,
                    backgroundColor: Colors.redAccent,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectMaker extends StatelessWidget {
  const _ObjectMaker({Key? key, required this.pharos}) : super(key: key);
  final dynamic pharos;

  @override
  Widget build(BuildContext context) {
    if(pharos["maker"] != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width - 40,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              pharos["maker"]!,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontSize: 20,
                fontStyle: FontStyle.italic
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _Image extends StatelessWidget {
  const _Image({Key? key, required this.pharos}) : super(key: key);
  final dynamic pharos;

  @override
  Widget build(BuildContext context) {
    return ImageFullScreenWrapperWidget(
      child: Image.network(
        pharos['image']['data']['url'],
      ),
      dark: true,
    );
  }
}
