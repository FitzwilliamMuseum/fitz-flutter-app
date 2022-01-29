import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'favorites.dart';
import 'home.dart';
import 'utilities/icons.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  aboutText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: const TextSpan(
            text: 'About this app',
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
        ),
      ],
    );
  }

  aboutTextBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
            child: Text(
          "This is an experimental app to showcase the Fitzwilliam Museum's collection of objects and rich media. "
          "\n\nIt was built by Daniel Pett, using Flutter.\n\nVersion 1.0",
          textAlign: TextAlign.center,
        ))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.museum_outlined),
        tooltip: "View all our highlights",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 350,
                    child: Image.asset("assets/Portico.jpg",
                        fit: BoxFit.fill,
                        color: const Color.fromRGBO(117, 117, 117, 0.9),
                        colorBlendMode: BlendMode.modulate),
                  ),
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
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          iconSize: 30,
                          color: Colors.white,
                          icon: const Icon(Icons.home),
                          tooltip: "Go to app home page",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
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
                    padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                    child: Align(
                        alignment: Alignment.bottomCenter, child: fitzlogo()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 230, 0, 0),
                    child: Align(
                        alignment: Alignment.bottomCenter, child: rosette()),
                  ),
                ],
              ),
              Padding(padding: const EdgeInsets.all(20.0), child: aboutText()),
              Padding(
                  padding: const EdgeInsets.all(20.0), child: aboutTextBody()),
              SizedBox(width: 400, height: 100, child: pineapples()),
            ],
          ),
        ),
      ),
    );
  }
}
