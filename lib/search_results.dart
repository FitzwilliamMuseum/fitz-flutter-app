import 'dart:convert';
import 'package:fitz_museum_app/object_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'object_details.dart';
import 'home.dart';
import 'utilities/icons.dart';
import 'favorites.dart';
import 'about.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  final _controller = TextEditingController();

  fetchSearchData(String text) async {
    var request = await http.get(Uri.parse(
        "https://data.fitzmuseum.cam.ac.uk/search/results?operator=AND&sort=desc&format=json&query=$text"));
    return utf8.decode(request.bodyBytes);
  }

  _writeData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    if (list!.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("This item is already in your favorites!"),
      ));
    } else {
      list.add(id);

      prefs.setStringList("favorites", list);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Added to your favorites list"),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _deleteData(id);
          },
        ),
      ));
    }
  }

  _deleteData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    list!.remove(id);

    prefs.setStringList("favorites", list);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Removed from your favorites list"),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _writeData(id);
        },
      ),
    ));
  }

  bool visibility = false;
  int count = 0;

  builder(String query) {
    visibility = true;

    return FutureBuilder(
      future: fetchSearchData(query),
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
        var dataSearch = jsonDecode(snapshot.data.toString());
        if (dataSearch['results'].length > 0) {
          var data = dataSearch['results'];
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final result = data[index]['_source'];
              const contentUrl =
                  'https://data.fitzmuseum.cam.ac.uk/imagestore/';
              dynamic image;
              try {
                if (result.containsKey('multimedia')) {
                  image = Image.network(
                    contentUrl +
                        result['multimedia'][0]['processed']['large']
                            ['location'],
                    fit: BoxFit.fitWidth,
                    colorBlendMode: BlendMode.modulate,
                    color: const Color.fromRGBO(255, 255, 255, 0.7),
                  );
                } else {
                  image = Image.asset(
                    'assets/Portico.jpg',
                    fit: BoxFit.fitHeight,
                    colorBlendMode: BlendMode.modulate,
                    color: const Color.fromRGBO(255, 255, 255, 0.7),
                  );
                }
              } on TypeError {
                return const SizedBox.shrink();
              }
              final String title;
              if (result.containsKey('title')) {
                title = result['title'][0]['value'];
              } else {
                title = result['summary_title'];
              }
              final id =
                  result['admin']['id'].toString().replaceAll('object-', '');

              return Card(
                  color: Colors.black,
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ObjectPage(id: id)),
                        );
                      },
                      child: Stack(clipBehavior: Clip.none, children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: image,
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 20, 20),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                'assets/pineApple.png',
                                width: 60,
                                height: 60,
                              ),
                            )),
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 160, 0, 0),
                              child: Text(title.toCapitalized(),
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 20.0, color: Colors.white)),
                            ),
                          ],
                        )
                      ])));
            },
          );
        } else {
          return const Align(
            alignment: Alignment.center,
            child: Text("No results found!"),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var text = widget.text;

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
              Stack(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 450,
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
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          iconSize: 30,
                          color: Colors.white,
                          icon: const Icon(Icons.info),
                          tooltip: "About this app",
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
                    child: Align(
                        alignment: Alignment.bottomCenter, child: fitzlogo()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 230, 0, 0),
                    child: Align(
                        alignment: Alignment.bottomCenter, child: rosette()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 330, 30, 20),
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (String value) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        SearchResultsPage(
                                            text: _controller.text)));
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(99),
                                ),
                              ),
                              filled: true,
                              hintText: "Search our collection",
                              fillColor: Colors.white),
                        )),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text('Your search results for ' + widget.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0, color: Colors.black)),
              ),
              builder(text),
              SizedBox(width: 400, height: 100, child: pineapples()),
            ],
          ),
        ),
      ),
    );
  }
}
