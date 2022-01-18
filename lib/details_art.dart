import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailsPage extends StatefulWidget {
  const DetailsPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData(String id) async {
    var request = await http.get(Uri.parse("https://data.fitzmuseum.cam.ac.uk/id/object/66173/json"));
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

  builder(String id) {
    return FutureBuilder(
      future: fetchData(id),
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

        Widget leading;
        var artist;
        var title;

        try {
          if (data["primaryImageSmall"] == "") {
            leading = const Icon(Icons.dangerous, size: 50, color: Colors.red,);
          }
          else {
            leading = Image.network(data["primaryImageSmall"]);
          }

          if (data["artistDisplayName"]== "") {
            artist = "Unknown";
          }
          else {
            artist = data["artistDisplayName"];
          }

          if (data["summary_title"]["value"]== "") {
            title = "Unknown";
          }
          else {
            title = data["summary_title"]["value"];
          }
        }
        on TypeError {
          return const SizedBox.shrink();
        }

        return Column(
          children: <Widget>[
            leading,
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text( "Title: " ),
                  Expanded(
                    child: Text(data["title"].toString()),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Object Name: "
                  ),
                  Expanded(
                    child: Text(
                      data["objectName"].toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Artist: "
                  ),
                  Expanded(
                    child: Text(
                      artist.toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text("Object ID: "),
                  Expanded(
                    child: Text( data["objectID"].toString()),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Is Highlighted: "
                  ),
                  Expanded(
                    child: Text(
                      data["isHighlight"].toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Date: "),
                  Expanded(
                    child: Text(
                      data["objectDate"].toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Accession Year: "

                  ),
                  Expanded(
                    child: Text(
                      data["accessionYear"].toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Accession Number: "
                  ),
                  Expanded(
                    child: Text(
                      data["accessionNumber"].toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text("Department: "),
                  Expanded(
                    child: Text( data["department"].toString()),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Culture: "
                  ),
                  Expanded(
                    child: Text(
                      title.toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Dimensions: "
                  ),
                  Expanded(
                    child: Text(
                      data["dimensions"].toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Credit Line: "
                  ),
                  Expanded(
                    child: Text(
                      data["creditLine"].toString()
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  const Text(
                    "Object URL: "
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Link",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launch(data["objectURL"], forceSafariVC: false);
                        }
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 7),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)
                ),
                onPressed: () {
                  _writeData(data["objectID"].toString());
                },
                child: const Text("Add to Favorites"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Details"),
      ),
      body: ListView(
        children: <Widget>[
          builder(widget.id),
        ],
      ),
    );
  }
}
