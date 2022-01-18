import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'all.dart';
import 'about.dart';
import 'home.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends ConsumerState<NewsPage> {
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
                subtitle: Text(result.date),
            trailing: const Icon(Icons.more_vert),
            onTap: () async {
              if (!await launch(result.url)) {
                throw 'Could not launch ${result.url}';
              }
            },
          ));
        },
      ),
      error: (e, st) =>
          Text(e.toString(), style: Theme.of(context).textTheme.headline5),
      loading: () => const Center(
        child: CircularProgressIndicator(),
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
            MaterialPageRoute(builder: (context) => const AllPage()),
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
                    )),
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
              newsHeadlineText(),
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
    required this.title,
      required this.date,
      required this.url,
      required this.excerpt,
      required this.image
  });

  final String title;
  final String date;
  final String url;
  final String excerpt;
  final String image;

  factory SearchResult.fromJson(Map<String, dynamic> data) {
    return SearchResult(
        title: data['article_title'],
        date: data['publication_date'],
        url: 'https://fitz.ms',
        image: data['field_image']['data']['thumbnails'][2]['url'],
        excerpt: data["article_excerpt"]
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
        'https://content.fitz.ms/fitz-website/items/news_articles?fields=article_title,id,publication_date,*.*&sort=-id&limit=6'));
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
            child: Text("Latest News",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30.0, color: Colors.black)))
      ],
    ),
  );
}

pineapple() {
  return Image.asset('assets/pineapple.jpg', height: 80, width: 80);
}