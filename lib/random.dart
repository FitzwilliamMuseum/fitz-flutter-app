import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'about.dart';
import 'home.dart';
import 'utilities/fullscreen.dart';

class RandomPage extends ConsumerStatefulWidget {
  const RandomPage({Key? key}) : super(key: key);

  @override
  RandomPageState createState() => RandomPageState();
}

class RandomPageState extends ConsumerState<RandomPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  record() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
      data: (results) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          const contentUrl = 'https://data.fitzmuseum.cam.ac.uk/imagestore/';
          final Image leading;
          leading = Image.network(
            contentUrl + result.image,
          );
          final title = result.fullTitle;
          final maker = result.maker;
          final description = result.description;
          final department = result.department;
          final accession = result.accession;
          _launchURL() async {
            if (await canLaunch(result.url)) {
              await launch(result.url);
            } else {
              throw 'Could not launch $result.url';
            }
          }

          return Column(
            children: <Widget>[
              ImageFullScreenWrapperWidget(
                child: leading,
                dark: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30.0, color: Colors.black)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(accession,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 30.0, color: Colors.black)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Made by: ' + maker!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20.0, color: Colors.purple)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(description!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('In the collection of ' + department!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _launchURL,
                      child: const Text('View online'),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      error: (e, st) =>
          Text(e.toString(), style: Theme.of(context).textTheme.headline5),
      loading: () => SizedBox(
        height: 400,
        width: 400,
        child: Image.asset('assets/rosetteRotate.gif', height: 150, width: 150),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.museum_outlined),
        tooltip: "View all our highlights",
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
                record(),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        iconSize: 30,
                        color: Colors.white,
                        icon: const Icon(Icons.home),
                        tooltip: "Go to app home page",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                      ),
                    )
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
                    )
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
              explore(),
              pineapple()
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResult {
  SearchResult(
      {required this.title,
      required this.url,
      required this.image,
      required this.accession,
      this.fullTitle,
      this.maker,
      this.description,
      this.department});

  final String title;
  final String url;
  final String image;
  final String accession;
  final String? fullTitle;
  final String? maker;
  final String? description;
  final String? department;

  factory SearchResult.fromJson(Map<String, dynamic> data) {
    final identifier = data["identifier"][0];
    print(identifier);
    return SearchResult(
        title: data['summary_title'],
        url: data['admin']['uri'],
        image: data['multimedia'][0]['processed']['large']['location'],
        fullTitle: data.containsKey("title")
            ? data['title'][0]['value']
            : 'No full title',
        maker: data['lifecycle']['creation'][0].containsKey("maker")
            ? data['lifecycle']['creation'][0]['maker'][0]['summary_title']
            : 'No maker recorded',
        description: data.containsKey("description")
            ? data['description'][0]['value']
            : 'No description at the moment',
        department: data['department']['value'],
        accession: identifier.containsKey("accession_number")
            ? identifier['accession_number']
            : 'No accession number');
  }
}

class SearchResultsParser {
  SearchResultsParser();

  Future<List<SearchResult>> parseInBackground(String encodedJson) async {
    return compute(parse, encodedJson);
  }

  List<SearchResult> parse(String encodedJson) {
    final jsonData = jsonDecode(encodedJson);
    final resultsJson = jsonData['data'] as List<dynamic>;
    return resultsJson.map((json) => SearchResult.fromJson(json)).toList();
  }
}

class APIClient {
  Future<List<SearchResult>> downloadAndParseJson() async {
    final response = await http
        .get(Uri.parse('https://data.fitzmuseum.cam.ac.uk/random/app'));
    if (response.statusCode == 200) {
      final parser = SearchResultsParser();
      return parser.parseInBackground(response.body);
    } else {
      throw Exception('Failed to load json');
    }
  }
}

final apiClientProvider = Provider<APIClient>((ref) {
  return APIClient();
});

final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) {
  return ref.watch(apiClientProvider).downloadAndParseJson();
});

rosette() {
  return Image.asset('assets/rosette.png', height: 100, width: 100);
}

fitzlogo() {
  return Image.asset('assets/Fitz_logo_white.png', height: 150, width: 150);
}

explore() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      rosette(),
      rosette(),
      rosette(),
    ],
  );
}

newsHeadlineText() {
  return Padding(
    padding: const EdgeInsets.all(30.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
            child: Text("A random object from our collection",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30.0, color: Colors.black)))
      ],
    ),
  );
}

pineapple() {
  return Image.asset('assets/pineapple.jpg', height: 80, width: 80);
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
