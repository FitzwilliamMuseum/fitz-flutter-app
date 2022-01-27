import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'home.dart';
import 'favorites.dart';
import 'highlights.dart';
import 'about.dart';
import 'utilities/fullscreen.dart';

class ObjectPage extends StatefulWidget {
  const ObjectPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _ObjectPageState createState() => _ObjectPageState();
}

class _ObjectPageState extends State<ObjectPage>  {

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }


  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );
    return htmlText.replaceAll(exp, '');
  }

  fetchData(http.Client client,String id) async {
    var format = id.replaceAll('object-','') + '/json';
    final uri = "https://data.fitzmuseum.cam.ac.uk/id/object/" + format;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
  }

  fitzLogo() {
    return Image.asset('assets/Fitz_logo_white.png', height: 150, width: 150);
  }

  builder(id) {
    final number = id.toString();
    print(number);
    if (number is int) {
      print(number.toString());
    } else {
      print('fuck');
    }
    return FutureBuilder(
      future: fetchData(http.Client(),  number),
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
        final data = jsonDecode(snapshot.data.toString());
        final objectRecord = data;
        print(data);
        final dynamic leading;
        const contentUrl = 'https://data.fitzmuseum.cam.ac.uk/imagestore/';

        try {
          if (objectRecord.containsKey('multimedia')) {
            leading = Image.network(contentUrl + objectRecord['multimedia'][0]['processed']['large']['location'],
                  fit: BoxFit.fill,
                  color: const Color.fromRGBO(117, 117, 117, 0.9),
                  colorBlendMode: BlendMode.modulate
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
                )
            );
          }
        } on TypeError {
          return const SizedBox.shrink();
        }
        return Column(
          children: <Widget>[
            Stack(children: <Widget>[
              ImageFullScreenWrapperWidget(
                child: leading,
                dark: true,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      iconSize: 30,
                      color: Colors.white,
                      icon: const Icon(Icons.home),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  HomePage()),
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
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                  color: Colors.black,

                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                              objectRecord['summary_title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 30.0, color: Colors.white)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            ]),
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 1, 0, 2),
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

            explore(),
            pineapple()
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.museum_outlined),
        tooltip: "View all our highlights",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  HomePage()),
          );
        },
      ),
      resizeToAvoidBottomInset: false,
      body: ListView(
        children: <Widget>[
          builder(widget.id),
        ],
      ),
    );
  }
}


