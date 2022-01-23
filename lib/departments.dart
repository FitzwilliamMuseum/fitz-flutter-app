import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'details_art.dart';


class DepartmentsPage extends StatefulWidget {
  DepartmentsPage({required this.id, required this.name});

  final String id;
  final String name;

  @override
  _DepartmentsPageState createState() => _DepartmentsPageState();
}

class _DepartmentsPageState extends State<DepartmentsPage> {

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

  fetchSearchData() async {
    var request = await http.get(Uri.parse("https://collectionapi.metmuseum.org/public/collection/v1/search?departmentId=${widget.id}&q=%22%22"));

    return request.body;
  }

  _writeData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    if (list!.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("This item is already in your favorites!"),
          )
      );
    }
    else {
      list.add(id);

      prefs.setStringList("favorites", list);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Added to your favorites list"),
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
          content: Text("Removed from your favorites list"),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _writeData(id);
            },
          ),
        )
    );
  }

  var name;

  builder() {
    return FutureBuilder(
      future: fetchSearchData(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        var dataSearch = jsonDecode(snapshot.data.toString());

        if (dataSearch["total"] == 0) {
          return Align(
            alignment: Alignment.center,
            child: Text("No results found!", style: GoogleFonts.merriweatherSans(fontSize: 15, color: Colors.black)),
          );
        }

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
                  return Align(
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
                      leading = Icon(Icons.dangerous, color: Colors.red);
                    }
                    else {
                      leading = Image.network(data["primaryImageSmall"]);
                    }
                  }
                  on Exception {
                    leading = Icon(Icons.dangerous, color: Colors.red);
                  }

                  if (data["artistDisplayName"]== "") {
                    artist = "Unknown";
                  }
                  else {
                    artist = data["artistDisplayName"];
                  }
                }
                on TypeError {
                  return SizedBox.shrink();
                }


                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: leading,
                        title: Text(data["title"], style: GoogleFonts.merriweatherSans(),),
                        subtitle: Text(
                          "by $artist",
                          style: GoogleFonts.merriweatherSans(color: Colors.black.withOpacity(0.6)),
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
                            child: Text("Details", style: GoogleFonts.merriweatherSans(color: Colors.red)),
                          ),
                          TextButton(
                            onPressed: () {
                              _writeData(data["objectID"].toString());
                            },
                            child: Text("Add to Favorites", style: GoogleFonts.merriweatherSans(color: Colors.red)),
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
        title: Text("Department - ${widget.name}"),
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      body: ListView(
        children:  <Widget>[
          Scrollbar(
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: builder()
            ),
          )
        ],
      ),
    );
  }
}
