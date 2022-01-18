import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'details_art.dart';


class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  fetchData(String id) async {
    var request = await http.get(Uri.parse("https://collectionapi.metmuseum.org/public/collection/v1/objects/$id"));

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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your list is empty!"),
          )
      );
    }
    else {
      if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text("Are you sure?"),
              content: const Text("This will delete everything forever in your favorites list!"),
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
      }
      else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Are you certain?"),
              content: const Text("This will permanently delete all your favourite objects"),
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

        List list = (snapshot.data as List).map((e) => e as String).toList();

        int count = list.length;

        if (list.isEmpty) {
          return const Align(
            alignment: Alignment.center,
            child: Text("You have not saved any objects"),
          );
        }

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

                var leading;
                var artist;

                try {
                  try {
                    if (data["primaryImageSmall"] == "") {
                      leading = const Icon(Icons.dangerous, color: Colors.red);
                    }
                    else {
                      leading = Image.network(data["primaryImageSmall"]);
                    }
                  }
                  on TypeError {
                    leading = const Icon(Icons.dangerous, color: Colors.red);
                  }

                  if (data["artistDisplayName"]== "") {
                    artist = "Unknown";
                  }
                  else {
                    artist = data["artistDisplayName"];
                  }
                }
                on TypeError {
                  return const SizedBox.shrink();
                }


                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: leading,
                        title: Text(data["title"]),
                        subtitle: Text("by $artist"),
                      ),
                      ButtonBar(
                        alignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetailsPage(id: data["objectID"].toString())),
                              );
                            },
                            child: const Text("Details"),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteData(id);
                            },
                            child: const Text("Remove from Favorites"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Favorites"),
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        actions: [
          IconButton(
            onPressed: () {
              _deleteAll();
            },
            icon: const Icon(Icons.delete_forever)
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: builder()
          ),
          Image.asset(
            'assets/pineapple.png',
            height: 200,
            width:  200,
          ),
        ],
      ),
    );
  }
}