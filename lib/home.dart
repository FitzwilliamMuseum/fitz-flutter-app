import 'package:fitz_museum_app/highlights.dart';
import 'package:fitz_museum_app/random.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fitz_museum_app/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:card_swiper/card_swiper.dart';

import 'about.dart';

// import 'carousel.dart';
import 'favorites.dart';
import 'news.dart';
import 'api/exhibitions.dart';

// import 'departments.dart';
import 'random.dart';
import 'covid.dart';
import 'highlights.dart';
import 'podcasts.dart';

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
      padding: const EdgeInsets.all(30.0),
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

  news() {
    return IconButton(
      iconSize: 48,
      color: Colors.black,
      icon: const Icon(Icons.article_outlined),
      tooltip: "Latest news",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewsPage()),
        );
      },
    );
  }

  random() {
    return IconButton(
      iconSize: 48,
      color: Colors.black,
      icon: const FaIcon(FontAwesomeIcons.random),
      tooltip: "Random object finder",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RandomPage()),
        );
      },
    );
  }

  podcastShow() {
    return IconButton(
      iconSize: 48,
      color: Colors.black,
      icon: const FaIcon(FontAwesomeIcons.headphones),
      tooltip: "Recent podcasts",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PodcastsPage()),
        );
      },
    );
  }

  swiper() {
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PodcastsPage()),
            );
          }, // Image tapped
          child: Image.asset(
            'assets/hockney.jpg',
            fit: BoxFit.fill, // Fixes border issues
          ),
        );
      },
      itemCount: 10,
      viewportFraction: 0.8,
      scale: 0.9,
      layout: SwiperLayout.TINDER,
      itemWidth: 300.0,
      itemHeight: 400.0,
      pagination: const SwiperPagination(
        margin: EdgeInsets.all(45.0),
        builder: DotSwiperPaginationBuilder(
            color: Colors.black, activeColor: Colors.red),
      ),
      control: const SwiperControl(),
    );
  }

  highlights() {
    return IconButton(
      iconSize: 48,
      color: Colors.black,
      icon: const Icon(Icons.image_search_outlined),
      tooltip: "Find our highlights",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HighlightsPage()),
        );
      },
    );
  }

  masks() {
    return SizedBox(
      width: 60,
      child: IconButton(
        iconSize: 40,
        color: Colors.black,
        icon: const Icon(Icons.masks),
        tooltip: "View latest corona virus info",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CovidPage()),
          );
        },
      ),
    );
  }

  actionExplorer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [news(), masks(), highlights(), random(), podcastShow()],
      ),
    );
  }

  aboutTextBody() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Explore the Fitz",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.museum_outlined),
      //   tooltip: "View all our highlights",
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const HighlightsPage()),
      //     );
      //   },
      // ),
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
                                      SearchPage(text: _controller.text)));
                        },
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(99),
                              ),
                            ),
                            filled: true,
                            hintText: "Search collection highlights",
                            fillColor: Colors.white),
                      )),
                ),
              ]),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width,
              //   // height: 400,
              //   child: Image.asset(
              //       "assets/hockney.jpg",
              //       fit: BoxFit.fill,
              //   ),
              // ),

              aboutTextBody(),
              actionExplorer(),
              youtubeText(),
              youtube(),
              // carousel(),
              explore(),

              Stack(children: <Widget>[
                Container(height: 421, child: ExPage()),
              ]),
              pineapple(),
            ],
          ),
        ),
      ),
    );
  }
}
