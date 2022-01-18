import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'details_art.dart';


// ignore: use_key_in_widget_constructors
class AllPage extends StatefulWidget {
  const AllPage({Key? key}) : super(key: key);

  @override
  _AllPageState createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> {

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

  fetchAllData() async {
    var request = await http.get(Uri.parse("https://collectionapi.metmuseum.org/public/collection/v1/objects"));

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

  builder() {
    return FutureBuilder(
      future: fetchAllData(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: LinearProgressIndicator(),
            ),
          );
        }
        var data = jsonDecode(snapshot.data.toString());

        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: data["total"],
          itemBuilder: (BuildContext context, int index) {
            var id = data["objectIDs"][index];

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
                        title: Text(data["title"]),
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
                            child: const Text("Add to Favorites"),
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
        title: const Text("Highlights of the collection"),
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      body: ListView(
        children: <Widget>[
          const Align(
            alignment: Alignment.topCenter,
            child: Text(
                "Discover our curated highlights",
                style: TextStyle(fontSize: 20.0, color: Colors.white)
            )
          ),
          Scrollbar(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: builder()
            ),
          )
        ],
      )
    );
  }
}
