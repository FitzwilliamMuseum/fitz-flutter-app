import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fitz_museum_app/search_results.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'about.dart';
import 'favorites.dart';
import 'api/exhibitions.dart';
import 'api/explore_fitz_cards.dart';

// ignore: use_key_in_widget_constructors
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String videoID = 'zrlEJ_3fWds';
  final YoutubePlayerController _controllerYT = YoutubePlayerController(
    initialVideoId: videoID,
    flags: const YoutubePlayerFlags(
      autoPlay: false,
      mute: false,
    ),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData() async {
    var request = await http.get(Uri.parse(
        "https://content.fitz.ms/fitz-website/items/collections?fields=*.*.*.*"));
    return request.body;
  }

  _writeData(String id) async {
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
        content: const Text("Added to your favorite object list"),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _deleteData(id);
          },
        ),
      ));
    }
  }

  _deleteData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    list!.remove(id);

    prefs.setStringList("favorites", list);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Removed from your favorites object list"),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _writeData(id);
        },
      ),
    ));
  }

  final _controller = TextEditingController();

  rosette() {
    return Image.asset('assets/rosette.png', height: 100, width: 100);
  }

  youtubeText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 1, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Film in focus",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)))
        ],
      ),
    );
  }

  fitzLogo() {
    return Image.asset('assets/Fitz_logo_white.png', height: 150, width: 150);
  }

  youtube() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          YoutubePlayer(
            controller: _controllerYT,
            liveUIColor: Colors.white,
            showVideoProgressIndicator: true,
          )
        ],
      ),
    );
  }

  explore() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        rosette(),
        rosette(),
        rosette(),
      ],
    );
  }

  pineapple() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Image.asset('assets/pineapple.jpg', height: 80, width: 80),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Stack(children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  child: Image.asset("assets/Portico.jpg",
                      fit: BoxFit.fill,
                      color: const Color.fromRGBO(117, 117, 117, 0.9),
                      colorBlendMode: BlendMode.modulate),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
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
                      alignment: Alignment.bottomCenter, child: fitzLogo()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 240, 0, 0),
                  child: Align(
                      alignment: Alignment.bottomCenter, child: rosette()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 330, 30, 20),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (String value) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      SearchResultsPage(
                                          text: _controller.text)));
                        },
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(99),
                              ),
                            ),
                            filled: true,
                            hintText: "Search our collection",
                            fillColor: Colors.white),
                      )),
                ),
              ]),
              Stack(children: const <Widget>[
                Padding(
                  padding: EdgeInsets.all(0),
                  child: SizedBox(
                      height: 300, width: 400, child: ExploreActionsPage()),
                ),
              ]),
              StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: SizedBox(
                      height: 300,
                      child: Stack(children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'galleries');
                          },
                          child: Image.network(
                            "https://fitz-cms-images.s3.eu-west-2.amazonaws.com/fitzwilliam-museum-main-entrance-2018_3-1.jpg",
                            fit: BoxFit.cover,
                            height: 300,
                            colorBlendMode: BlendMode.modulate,
                            color: const Color.fromRGBO(255, 255, 255, 0.9),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 140, 20, 20),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 4.0,
                                    color: Colors.lightBlue.shade600),
                              ),
                            ),
                            child: const Text('Our galleries',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.white)),
                          ),
                        )
                      ]),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Stack(children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'research');
                          },
                          child: Image.network(
                            'https://fitz-cms-images.s3.eu-west-2.amazonaws.com/fitzwilliam-museum-19th-century-photograph.jpg',
                            fit: BoxFit.fill,
                            height: 300,
                            width: 300,
                            colorBlendMode: BlendMode.modulate,
                            color: const Color.fromRGBO(117, 117, 117, 0.9),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                          child: Container(
                            decoration:  BoxDecoration(
                              border: Border(
                                top:
                                    BorderSide(
                                        width: 2.0,
                                        color: Colors.lightBlue.shade600
                                    ),
                              ),
                            ),
                            child: const Text('Our history',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                )),
                          ),
                        )
                      ]),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Stack(children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'research');
                          },
                          child: Image.network(
                            'https://fitz-cms-images.s3.eu-west-2.amazonaws.com/xrf-analysis-of-an-illuminated-mss-at-the-fitz-1.jpg',
                            fit: BoxFit.fill,
                            height: 300,
                            width: 300,
                            colorBlendMode: BlendMode.modulate,
                            color: const Color.fromRGBO(117, 117, 117, 0.9),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                          child: Container(
                            decoration:  BoxDecoration(
                              border: Border(
                                top:
                                    BorderSide(
                                        width: 2.0,
                                        color: Colors.lightBlue.shade600
                                    ),
                              ),
                            ),
                            child: const Text('Our research',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                )),
                          ),
                        )
                      ]),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 2,
                    child: youtube(),
                  ),
                ],
              ),
              Stack(children: const <Widget>[
                SizedBox(height: 421, child: ExPage()),
              ]),
              pineapple(),
            ],
          ),
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.index,
    this.height,
    this.width,
    this.onTap,
  }) : super(key: key);

  final double? height;
  final double? width;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.red,
        height: height,
        width: width,
        child: Text('$index'),
      ),
    );
  }
}
