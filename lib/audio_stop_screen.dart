import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import 'utilities/fullscreen.dart';
import 'utilities/string_replace.dart';
import 'utilities/icons.dart';
import 'audioguide_list_screen.dart';

class AudioStopPage extends StatefulWidget {
  const AudioStopPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _AudioStopPageState createState() => _AudioStopPageState();
}

class _AudioStopPageState extends State<AudioStopPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/audio_guide?fields=*.*.*.*&limit=1&filter[stop_number][eq]=" +
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
        if(data.containsKey('data')) {
          final stop = data['data'];
          if(!stop.isEmpty ){
          final audio = stop[0];
          return Column(
            children: <Widget>[
              _ObjectTitle(audio: audio),
              _Image(audio: audio),
              _ObjectDescription(audio: audio),
              _Chip(audio: audio),
              pineappleSingle(),
            ],
          );} else {
            return Stack(
              children: const [
                _NothingFound(),
                _ViewAllStops()
              ],
            );
          }
        } else {
          return Stack(
            children: const [
              _NothingFound(),
              _ViewAllStops()
            ],
          );
        }
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
  const _Chip({Key? key, required this.audio}) : super(key: key);
  final dynamic audio;
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(audio["stop_number"].toString()),
    );
  }
}

class _ObjectTitle extends StatelessWidget {
  const _ObjectTitle({Key? key, required this.audio}) : super(key: key);
  final dynamic audio;

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
                audio["title"],
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
  const _ObjectDescription({Key? key, required this.audio}) : super(key: key);
  final dynamic audio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: MarkdownBody(
              data: removeAllHtmlTags(audio['transcription']),
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



class _Image extends StatelessWidget {
  const _Image({Key? key, required this.audio}) : super(key: key);
  final dynamic audio;

  @override
  Widget build(BuildContext context) {
    return ImageFullScreenWrapperWidget(
      child: Image.network(
        audio['hero_image']['data']['url'],
      ),
      dark: true,
    );
  }
}

class _NothingFound extends StatelessWidget {
  const _NothingFound({Key? key}) : super(key: key);

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
                'No stop was found with that number',
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                    fontSize: 30
                ),
              ),
            ),
          ),

        ],
      )
    );
  }
}

class _ViewAllStops extends StatelessWidget {
  const _ViewAllStops({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20,200,20,0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AudioGuideListPage()),
            );
          },
          child: const Text('See a list of all stops'),
          style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
              const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}