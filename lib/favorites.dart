import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'utilities/icons.dart';
import 'about.dart';
import 'object_details.dart';
import 'utilities/string_casing.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  fetchData(String id) async {
    var format = id + '/json';
    final uri = "https://data.fitzmuseum.cam.ac.uk/id/object/" + format;
    var request = await http.get(Uri.parse(uri));
    return request.body;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  _deleteAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    if (list!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Your list is empty!"),
      ));
    } else {
      if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text("Are you sure?"),
              content: const Text(
                  "This will delete everything forever in your favorites list!"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    prefs.setStringList("favorites", []);

                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
                TextButton(
                  child: const Text("CANCEL"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Are you certain?"),
              content: const Text(
                  "This will permanently delete all your favourite objects"),
              actions: [
                TextButton(
                  child: const Text("Okay"),
                  onPressed: () {
                    prefs.setStringList("favorites", []);
                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          },
        );
      }
    }
  }

  favoritesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("favorites");
  }

  _deleteData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    list!.remove(id);

    prefs.setStringList("favorites", list);
    setState(() {});
  }

  builder() {
    return FutureBuilder(
      future: favoritesList(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          /// Here
          List list = (snapshot.data as List).map((e) => e as String).toList();
          int count = list.length;
          if (list.isEmpty) {
            return const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    "You have not saved any objects to your list of favourites",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.0, color: Colors.purple)),
              ),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: count,
              itemBuilder: (BuildContext context, int index) {
                String id = list[index];
                return FutureBuilder(
                  future: fetchData(id.toString()),
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

                    var data = jsonDecode(snapshot.data.toString());
                    final objectRecord = data;
                    final String title;
                    if (objectRecord.containsKey('title')) {
                      title = objectRecord['title'][0]['value'];
                    } else {
                      title = objectRecord['summary_title'];
                    }
                    final String id;
                    id = objectRecord['admin']['id'];
                    dynamic leading;
                    const contentUrl =
                        'https://data.fitzmuseum.cam.ac.uk/imagestore/';
                    try {
                      if (objectRecord.containsKey('multimedia')) {
                        leading = Image.network(
                          contentUrl +
                              objectRecord['multimedia'][0]['processed']['large']
                              ['location'],
                          fit: BoxFit.fitWidth,
                          colorBlendMode: BlendMode.modulate,
                          color: const Color.fromRGBO(255, 255, 255, 0.7),
                        );
                      } else {
                        leading = Image.asset(
                          'assets/Portico.jpg',
                          fit: BoxFit.fitHeight,
                          colorBlendMode: BlendMode.modulate,
                          color: const Color.fromRGBO(255, 255, 255, 0.7),
                        );
                      }
                    } on TypeError {
                      return const SizedBox.shrink();
                    }
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
                                child: leading,
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
                                    padding: const EdgeInsets.fromLTRB(30, 160, 0, 0),
                                    child: Text(title.toCapitalized(),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 20.0, color: Colors.white)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteData(
                                          id.replaceAll('object-', '').toString());
                                    },
                                    child: const Text("Remove from Favorites"),
                                  ),
                                ],
                              )
                            ])));
                  },
                );
              },
            );
          }
        } else {
          return const Text('Empty results');
        }

        /// HERE
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
                        icon: const Icon(Icons.delete_forever),
                        tooltip: "Delete all favourites",
                        onPressed: () {
                          _deleteAll();
                        },
                      ),
                    )),
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
                      alignment: Alignment.bottomCenter, child: fitzLogo()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 230, 0, 0),
                  child: Align(
                      alignment: Alignment.bottomCenter, child: rosetteSingle()),
                ),
              ]),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                    'Your favourites',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30.0, color: Colors.black)
                ),
              ),
              builder(),
              pineapples(),
            ],
          ),
        ),
      ),
    );
  }
}
