import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'utilities/icons.dart';
import 'utilities/string_replace.dart';

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

  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/exhibitions?fields=exhibition_title,exhibition_start_date,exhibition_end_date,tessitura_string,id,slug,exhibition_narrative,exhibition_abstract,hero_image.*,type,exhibition_status&sort=-exhibition_end_date&limit=1&filter[id][eq]=" +
            id;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
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

  builder(id) {
    return FutureBuilder(
      future: fetchData(http.Client(), id),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return errorLoadingRosette();
        }
        final data = jsonDecode(snapshot.data.toString());
        final exhibition = data['data'];
        return Column(
          children: <Widget>[
            _ExhibitionImage(exhibition: exhibition),
            _ExhibitionTitle(exhibition: exhibition),
            _ExhibitionDates(exhibition: exhibition),
            _TessituraButton(exhibition: exhibition),
            _ExhibitionBody(exhibition: exhibition),
            pineapples()
          ],
        );
      },
    );
  }
}

class _TessituraButton extends StatelessWidget {
  const _TessituraButton({Key? key, required this.exhibition})
      : super(key: key);
  final dynamic exhibition;

  @override
  Widget build(BuildContext context) {
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
      const url = 'https://tickets.museums.cam.ac.uk/overview/generaladmission';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    try {
      if (exhibition[0]["tessitura_string"] != null) {
        return SizedBox(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      } else {
        return SizedBox(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }
    } on TypeError {
      return const SizedBox.shrink();
    }
  }
}

class _ExhibitionTitle extends StatelessWidget {
  const _ExhibitionTitle({Key? key, required this.exhibition})
      : super(key: key);
  final dynamic exhibition;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _ExhibitionBody extends StatelessWidget {
  const _ExhibitionBody({Key? key, required this.exhibition}) : super(key: key);
  final dynamic exhibition;

  @override
  Widget build(BuildContext context) {
    final String narrative;
    if (exhibition[0]['exhibition_narrative'] != null) {
      narrative = exhibition[0]['exhibition_narrative'];
    } else if (exhibition[0]['exhibition_abstract'] != null) {
      narrative = exhibition[0]['exhibition_abstract'];
    } else {
      narrative = '';
    }
    return Padding(
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
    );
  }
}

class _ExhibitionImage extends StatelessWidget {
  const _ExhibitionImage({Key? key, required this.exhibition})
      : super(key: key);
  final dynamic exhibition;

  @override
  Widget build(BuildContext context) {
    try {
      if (exhibition[0]["hero_image"] == "") {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 350,
            child: Image.asset('assets/Portico.jpg',
                fit: BoxFit.fill,
                color: const Color.fromRGBO(117, 117, 117, 0.9),
                colorBlendMode: BlendMode.modulate),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: CircleAvatar(
                radius: 100.0,
                backgroundImage: NetworkImage(
                  exhibition[0]['hero_image']['data']['url'],
                ),
              )),
        );
      }
    } on TypeError {
      return const SizedBox.shrink();
    }
  }
}

class _ExhibitionDates extends StatelessWidget {
  const _ExhibitionDates({Key? key, required this.exhibition})
      : super(key: key);
  final dynamic exhibition;

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.tryParse(exhibition[0]['exhibition_start_date']);
    final endDate = DateTime.tryParse(exhibition[0]['exhibition_end_date']);

    return Padding(
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
                  style: const TextStyle(fontSize: 16.0, color: Colors.purple)),
            ),
          )
        ],
      ),
    );
  }
}
