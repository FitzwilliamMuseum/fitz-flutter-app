import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitz_museum_app/search_results.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'about.dart';
import 'favorites.dart';
import 'api/exhibitions.dart';
import 'api/explore_fitz_cards.dart';
import 'ui/staggered_collection.dart';
import 'utilities/icons.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// ignore: use_key_in_widget_constructors
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int counter = 3;

  final YoutubePlayerController _controllerYouTube = YoutubePlayerController(
    initialVideoId: 'zrlEJ_3fWds',
    params: const YoutubePlayerParams(
      startAt: Duration(seconds: 0),
      showControls: true,
      showFullscreenButton: true,
      enableKeyboard: true,
      enableCaption: false,
      privacyEnhanced: true,
      strictRelatedVideos: true
    ),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  final _controller = TextEditingController();

  youtube() {
    return YoutubePlayerIFrame(
        controller: _controllerYouTube, aspectRatio: 16 / 9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(

        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              Stack(children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 410,
                  child: Image.asset("assets/Portico.jpg",
                      fit: BoxFit.fill,
                      color: const Color.fromRGBO(117, 117, 117, 0.9),
                      colorBlendMode: BlendMode.modulate),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 20, 20),
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
                    padding: const EdgeInsets.fromLTRB(0, 50, 60, 20),
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
                      alignment: Alignment.bottomCenter,
                      child: rosetteSingle()),
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
                          prefixIcon: Icon(Icons.search_sharp),
                          prefixIconColor: Colors.purple,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          filled: true,
                          hintText: "Search our collection",
                          fillColor: Colors.white70,
                          hintStyle: TextStyle(color: Colors.black),
                        ),
                      )),
                ),
              ]),
              Stack(children:  <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: const ExploreActionsPage()
                  ),
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
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  width: 4.0,
                                  color: Color(0xA1ADD5BB),
                                ),
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
                            Navigator.pushNamed(context, '3d');
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
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  width: 2.0,
                                  color: Color(0xA1ADD5BB),
                                ),
                              ),
                            ),
                            child: const Text('3D models',
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
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 2.0, color: Color(0xA1ADD5BB)),
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
              const StaggeredCollection(),
              StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 2,
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
                            Navigator.pushNamed(context, 'audioguide');
                          },
                          child: Image.network(
                            "https://fitz-cms-images.s3.eu-west-2.amazonaws.com/pd_30_1948.jpeg",
                            fit: BoxFit.cover,
                            height: 300,
                            colorBlendMode: BlendMode.modulate,
                            color: const Color.fromRGBO(255, 255, 255, 0.9),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 140, 20, 20),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  width: 4.0,
                                  color: Color(0xA1ADD5BB),
                                ),
                              ),
                            ),
                            child: const Text('Audio Guide',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.white)),
                          ),
                        ),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Icon(
                              IconData(0xf0f0, fontFamily: 'MaterialIcons'),
                              size: 60,
                            ),
                          ),
                        ),
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
                            Navigator.pushNamed(context, 'iiif');
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
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  width: 2.0,
                                  color: Color(0xA1ADD5BB),
                                ),
                              ),
                            ),
                            child: const Text('IIIF images',
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
                            Navigator.pushNamed(context, 'augmented');
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
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 2.0, color: Color(0xA1ADD5BB)),
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
                ],
              ),
              Padding(padding: const EdgeInsets.all(40),child: pineappleSingle())
              ,
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
