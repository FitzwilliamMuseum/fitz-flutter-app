import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class DetailsPage extends StatefulWidget {
  DetailsPage({required this.id});

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
    var request = await http.get(Uri.parse("https://collectionapi.metmuseum.org/public/collection/v1/objects/$id"));

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

  builder(String id) {
    return FutureBuilder(
      future: fetchData(id),
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
        var culture;

        try {
          if (data["primaryImageSmall"] == "") {
            leading = Icon(Icons.dangerous, size: 50, color: Colors.red,);
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

          if (data["culture"]== "") {
            culture = "Unknown";
          }
          else {
            culture = data["culture"];
          }
        }
        on TypeError {
          return SizedBox.shrink();
        }

        return Column(
          children: <Widget>[
            leading,
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Title: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["title"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Object Name: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["objectName"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Artist: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      artist.toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Object ID: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["objectID"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Is Highlighted: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["isHighlight"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Date: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["objectDate"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Accession Year: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["accessionYear"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Accession Number: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["accessionNumber"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Department: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["department"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Culture: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      culture.toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Dimensions: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["dimensions"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Credit Line: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  Expanded(
                    child: Text(
                      data["creditLine"].toString(),
                      style: GoogleFonts.merriweatherSans(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 0),
              child: Row(
                children: [
                  Text(
                    "Object URL: ",
                    style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.red),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Link",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await launch(data["objectURL"], forceSafariVC: false);
                        },
                      style: GoogleFonts.merriweatherSans(fontSize: 20, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 0, 7),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)
                ),
                onPressed: () {
                  _writeData(data["objectID"].toString());
                },
                child: Text("Add to Favorites", style: GoogleFonts.merriweatherSans(color: Colors.white)),
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
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("Details", style: GoogleFonts.merriweatherSans(color: Colors.white)),
      ),
      body: ListView(
        children: <Widget>[
          builder(widget.id),
        ],
      ),
    );
  }
}
