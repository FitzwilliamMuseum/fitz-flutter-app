import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'details_art.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({required this.text});

  final String text;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData(String id) async {
    var request = await http.get(Uri.parse("https://collectionapi.metmuseum.org/public/collection/v1/objects/$id"));

    return request.body;
  }

  fetchSearchData(String query) async {
    var request = await http.get(Uri.parse("https://collectionapi.metmuseum.org/public/collection/v1/search?q=$query"));

    return request.body;
  }

  _writeData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    if (list!.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This item is already in your favorites!"),
          )
      );
    }
    else {
      list.add(id);

      prefs.setStringList("favorites", list);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Added to your favorites list"),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                _deleteData(id);
              },
            ),
          )
      );
    }
  }

  _deleteData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    list!.remove(id);

    prefs.setStringList("favorites", list);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Removed from your favorites list"),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _writeData(id);
            },
          ),
        )
    );
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

        if (dataSearch["total"] == 0) {
          return const Align(
            alignment: Alignment.center,
            child: Text("No results found!"),
          );
        }

        visibility = true;
        count = dataSearch["total"];

        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: dataSearch["total"],
          itemBuilder: (BuildContext context, int index) {
            var id = dataSearch["objectIDs"][index];

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
                  on Exception {
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
                        title: Text(
                            data["title"]
                        ),
                        subtitle: Text(
                          "by $artist"
                        ),
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
                              _writeData(data["objectID"].toString());
                            },
                            child:  const Text( "Add to Favorites" ),
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
    var text = widget.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      body: ListView(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Text(
                "Search results for $text"
            ),
          ),
          Scrollbar(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: builder(text)
            ),
          )
        ],
      ),
    );
  }
}
