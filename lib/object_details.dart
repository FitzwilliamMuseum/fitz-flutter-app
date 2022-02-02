import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

// import 'package:flutter_markdown/flutter_markdown.dart';

import 'utilities/fullscreen.dart';
import 'utilities/icons.dart';
import 'utilities/string_casing.dart';
import 'utilities/string_replace.dart';

class ObjectPage extends StatefulWidget {
  const ObjectPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _ObjectPageState createState() => _ObjectPageState();
}

class _ObjectPageState extends State<ObjectPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData(http.Client client, String id) async {
    var format = id.replaceAll('object-', '') + '/json';
    final uri = "https://data.fitzmuseum.cam.ac.uk/id/object/" + format;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
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

  builder(id) {
    final number = id.toString();
    return FutureBuilder(
      future: fetchData(http.Client(), number),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 400,
            child:  Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        final data = jsonDecode(snapshot.data.toString());
        final objectRecord = data;
        final dynamic leading;
        const contentUrl = 'https://data.fitzmuseum.cam.ac.uk/imagestore/';
        try {
          if (objectRecord.containsKey('multimedia')) {
            leading = Image.network(
                contentUrl +
                    objectRecord['multimedia'][0]['processed']['large']
                        ['location'],
                fit: BoxFit.fitHeight
            );
          } else {
            leading = SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 250,
                child: const CircleAvatar(
                  radius: 100.0,
                  backgroundImage: AssetImage(
                    'assets/Portico.jpg',
                  ),
                ));
          }
        } on TypeError {
          return const SizedBox.shrink();
        }
        final String title;
        if (objectRecord.containsKey('title')) {
          title = objectRecord['title'][0]['value'];
        } else {
          title = objectRecord['summary_title'];
        }
        final dynamic description;
        if (objectRecord.containsKey('description')) {
          description = objectRecord['description'][0]['value'];
        } else {
          description = 'No description recorded currently.';
        }
        final String accession;
        if(objectRecord['identifier'][0]['accession_number'] != null){
          accession = objectRecord['identifier'][0]['accession_number'].toString();
        } else {
          accession = '';
        }

        return Column(
          children: <Widget>[
            Stack(children: <Widget>[
              SizedBox(
                width: 400,
                height: 400,
                child: ImageFullScreenWrapperWidget(
                  child: leading,
                  dark: true,
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              child: Text(
                title.toTitleCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              child: Text(
                accession,
                textAlign: TextAlign.center,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
              child: Text(
                description,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 0, 7),
              child: ElevatedButton(
                onPressed: () {
                  _writeData(number);
                },
                child: const Text('Add to your favourites'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            pineappleSingle()
          ],
        );
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
                portico(context),
                backIcon(context),
                aboutIcon(context),
                homeLogo(),
                homeRosette(),
                // favoritesIcon(context),
              ]),
              builder(widget.id),
            ],
          ),
        ),
      ),
    );
  }
}