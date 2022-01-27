///
/// http://localhost:8000/search/results?query=$query&operator=AND&sort=desc&format=json"

import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'about.dart';
import 'home.dart';
import 'object_details.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({Key? key, required this.text}) : super(key: key);
  final String text;
  @override
  SearchResultsPageState createState() => SearchResultsPageState();
}

class SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  var queryString;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    queryString = widget.text;
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
                leading: result.image,
                title: Text(result.title),
                // subtitle: Text(result.date),
                trailing: const Icon(Icons.more_vert),
                onTap: ()  {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ObjectPage(id: result.id.toString())),
                  );
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
      appBar: AppBar(
        title: const Text("Search"),
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.museum_outlined),
        tooltip: "Go home",
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: newsHeadlineText(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: searchText(widget.text),
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
    required this.title,
    required this.id,
    required this.image
  });

  final String title;
  final String id;
  final dynamic image;


  factory SearchResult.fromJson(Map<String, dynamic> data) {
    final dynamic objectInfo = data['_source'];
    final dynamic image;
    const contentUrl = 'https://data.fitzmuseum.cam.ac.uk/imagestore/';

    if (objectInfo.containsKey('multimedia')) {
        image =  Image.network(contentUrl + objectInfo['multimedia'][0]['processed']['large']['location']);
      } else {
        image = Image.asset('assets/Portico.jpg');
      }

    return SearchResult(
        title: objectInfo.containsKey("title") ? objectInfo['title'][0]['value'] : objectInfo['summary_title'],
        id: objectInfo['admin']['id'].replaceAll('object-','').toString(),
        image: image
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
    final resultsJson = jsonData['results']['data'] as List<dynamic>;
    return resultsJson.map((json) => SearchResult.fromJson(json)).toList();
  }
}

class APIClient extends SearchResultsPageState {

  Future<List<SearchResult>> downloadAndParseJson() async {
    var requestUrl = Uri.http("localhost:8000", "/search/result", {
      'query': queryString,
      'operator': 'AND',
      'sort': 'DESC',
      'format': 'json'}
      );
    print(widget.text);
    print(requestUrl);
    final response = await http.get(requestUrl);
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
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
            child: Text("Objects from our collection",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30.0, color: Colors.black)
            )
        ),
      ],
    ),
  );
}

searchText(message) {
  final string = 'You searched for ' + message;
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children:  [
        Flexible(
            child: Text(string,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20.0, color: Colors.purple)
            )
        ),
      ],
    ),
  );
}

pineapple() {
  return Image.asset('assets/pineapple.jpg', height: 80, width: 80);
}