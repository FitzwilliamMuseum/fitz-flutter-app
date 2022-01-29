import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'about.dart';
import 'home.dart';
import 'research_project.dart';

class ResearchPage extends ConsumerStatefulWidget {
  const ResearchPage({Key? key}) : super(key: key);

  @override
  ResearchPageState createState() => ResearchPageState();
}

class ResearchPageState extends ConsumerState<ResearchPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  newsItems() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
      data: (results) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return Card(
              child: ListTile(
                leading: Image.network(result.image),
                title: Text(result.title),
                trailing: const Icon(Icons.more_vert),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ProjectPage(id: result.id.toString())),
                  );
                },
              ));
        },
      ),
      error: (e, st) =>
          Text(e.toString(), style: Theme.of(context).textTheme.headline5),
      loading: () => SizedBox(
        height: 400,
        width: 400,
        child: Image.asset('assets/rosetteRotate.gif', height: 100, width: 100),
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
            MaterialPageRoute(builder: (context) =>  HomePage()),
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
                  height: 350,
                  child: Image.asset("assets/Portico.jpg",
                      fit: BoxFit.fill,
                      color: const Color.fromRGBO(117, 117, 117, 0.9),
                      colorBlendMode: BlendMode.modulate),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 60, 0),
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
                    padding: const EdgeInsets.fromLTRB(0, 50, 20, 20),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Align(
                      alignment: Alignment.bottomCenter, child: fitzlogo()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 230, 0, 0),
                  child: Align(
                      alignment: Alignment.bottomCenter, child: rosette()),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: newsHeadlineText(),
              ),

              newsItems(),
              explore(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResult {
  SearchResult({
    required this.id,
    required this.title,
    required this.url,
    required this.image
  });

  final String id;
  final String title;
  final String url;
  final String image;


  factory SearchResult.fromJson(Map<String, dynamic> data) {
    return SearchResult(
        id: data['id'].toString(),
        title: data['title'],
        url: data['slug'],
        image: data['hero_image']['data']['thumbnails'][2]['url'],
    );
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
    final response = await http.get(Uri.parse(
        "https://content.fitz.ms/fitz-website/items/research_projects?fields=*.*.*.*&sort=-id")
    );

    if (response.statusCode == 200) {
      final parser = SearchResultsParser();
      return parser.parseInBackground(utf8.decode(response.bodyBytes));
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
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
            child: Text("Our research projects",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30.0, color: Colors.black)
            )
        )
      ],
    ),
  );
}

pineapple() {
  return Image.asset('assets/pineapple.jpg', height: 80, width: 80);
}