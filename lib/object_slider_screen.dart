import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import 'utilities/fullscreen.dart';
import 'utilities/icons.dart';
import 'utilities/string_casing.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class ObjectSliderPage extends StatefulWidget {
  const ObjectSliderPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _ObjectSliderPageState createState() => _ObjectSliderPageState();
}

class _ObjectSliderPageState extends State<ObjectSliderPage> {

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

  @override
  Widget build(BuildContext context) {
    final number = widget.id.toString();
    return FutureBuilder(
      future: fetchData(http.Client(), number),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return errorLoadingRosette();
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
                fit: BoxFit.fitHeight,
                height: 450
            );
          } else {
            leading = Image.asset('assets/Portico.jpg',
                fit: BoxFit.fitHeight,
                height: 450
            );
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
          var textToDisplay = [];
          for (var desc in objectRecord['description']) {
            textToDisplay.add(desc["value"]);
          }
          description = textToDisplay.join('\n\n');
        } else {
          description = 'No description recorded currently.';
        }
        final String accession;
        if (objectRecord['identifier'][0]['accession_number'] != null) {
          accession =
              objectRecord['identifier'][0]['accession_number'].toString();
        } else {
          accession = '';
        }
        return Scaffold(
            floatingActionButton: floatingHomeButton(context),
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: SlidingSheet(
              elevation: 8,
              cornerRadius: 16,
              snapSpec: const SnapSpec(
                // Enable snapping. This is true by default.
                snap: true,
                // Set custom snapping points.
                snappings: [0.2, 0.7, 1.0],
                positioning: SnapPositioning.relativeToAvailableSpace,
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                  children: [
                    Stack(
                      children: [backIconDark(context), aboutIconDark(context)],
                    ),
                    _ObjectImage(image: leading),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        _AddToFavoritesButton(number: number),
                        // _ViewInARButton(number: number),
                        // _button(Icons.zoom_in_rounded, Colors.black),
                      ],
                    ),
                    // InteractiveViewer(
                    //   child: Image.network(contentUrl +
                    //       objectRecord['multimedia'][0]['processed']['large']
                    //       ['location']),
                    //   boundaryMargin: EdgeInsets.all(5.0),
                    // ),
                  ],
                ),
              ),
              builder: (context, state) {
                return SizedBox(
                  height: 900,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          _ObjectTitle(title: title),
                          _AccessionNumber(accession: accession),
                          _ObjectDescription(description: description),
                          pineappleSingle()
                        ],
                      ),
                    ),
                  ),
                );
              },
            ));
      },
    );
  }
}

class _ObjectImage extends StatelessWidget {
  const _ObjectImage({Key? key, required this.image}) : super(key: key);
  final dynamic image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: ZoomOverlay(
        minScale: 0.5, // optional
        maxScale: 3.0, // optional
        twoTouchOnly: true,
        animationDuration: const Duration(milliseconds: 100),
        child: (
            ImageFullScreenWrapperWidget(
              child: image,
              dark: true,
            )
        ),
      ),
    );
  }
}

class _ObjectTitle extends StatelessWidget {
  const _ObjectTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Text(
        title.toTitleCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AccessionNumber extends StatelessWidget {
  const _AccessionNumber({Key? key, required this.accession}) : super(key: key);
  final String accession;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Text(
        accession,
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ObjectDescription extends StatelessWidget {
  const _ObjectDescription({Key? key, required this.description})
      : super(key: key);
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Text(
        description.toCapitalized(),
        textAlign: TextAlign.left,
        style: GoogleFonts.openSans(fontSize: 16),
      ),
    );
  }
}

class _AddToFavoritesButton extends StatelessWidget {
  const _AddToFavoritesButton({Key? key, required this.number})
      : super(key: key);
  final String number;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.white,
              onPressed: () {
                _writeData(number, context);
              }),
          decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 8.0,
                )
              ]),
        ),
        const SizedBox(
          height: 20.0,
        )
      ],
    );
  }
}

_writeData(String id, context) async {
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
          _deleteData(id, context);
        },
      ),
    ));
  }
}

_deleteData(String id, context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var list = prefs.getStringList("favorites");

  list!.remove(id);
  prefs.setStringList("favorites", list);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text("Removed from your favorites list"),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        _writeData(id, context);
      },
    ),
  ));
}

Widget _button(IconData icon, Color color) {
  return Column(
    children: <Widget>[
      Container(
        padding: const EdgeInsets.all(18.0),
        child: Icon(icon, color: Colors.white, size: 30.0),
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.15),
                blurRadius: 8.0,
              )
            ]),
      ),
      const SizedBox(
        height: 18.0,
      )
    ],
  );
}

class _ViewInARButton extends StatelessWidget {
  const _ViewInARButton({Key? key, required this.number}) : super(key: key);
  final String number;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(5.0),
          child: IconButton(
              icon: const Icon(Icons.view_in_ar),
              color: Colors.white,
              onPressed: () {
                _writeData(number, context);
              }),
          decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 8.0,
                )
              ]),
        ),
        const SizedBox(
          height: 20.0,
        )
      ],
    );
  }
}
