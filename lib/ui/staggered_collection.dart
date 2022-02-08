import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../highlight.dart';

class StaggeredCollection extends StatefulWidget {
  const StaggeredCollection({Key? key}) : super(key: key);

  @override
  _StaggeredCollection createState() => _StaggeredCollection();
}

class _StaggeredCollection extends State<StaggeredCollection> {
  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HighlightPage(id: '74')),
                  );
                },
                child: Image.network(
                  "https://content.fitz.ms/fitz-website/assets/103_LRG.jpg",
                  fit: BoxFit.cover,
                  height: 300,
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
                  child: const Text('Van Heemskerk',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18.0, color: Colors.white)),
                ),
              )
            ]),
          ),
        ),
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 2,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Stack(children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HighlightPage(id: '28')),
                  );
                },
                child: Image.network(
                    'https://content.fitz.ms/fitz-website/assets/CupidPsycheLarge.jpg?key=directus-large-crop',
                    fit: BoxFit.cover,
                    width: 300,
                    height: 400),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 150, 20, 20),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 4.0,
                        color: Color(0xA1ADD5BB),
                      ),
                    ),
                  ),
                  child: const Text('Cupid and Psyche',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16.0, color: Colors.white)),
                ),
              )
            ]),
          ),

        ),
        StaggeredGridTile.count(
            crossAxisCellCount: 4,
            mainAxisCellCount: 2,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Stack(children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HighlightPage(id: '27')),
                    );
                  },
                  child: Image.network(
                    "https://fitz-cms-images.s3.eu-west-2.amazonaws.com/panel-1.jpg",
                    fit: BoxFit.fill,
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
                    child: const Text('Simone Martini',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20.0, color: Colors.white)),
                  ),
                ),
              ]),
            )),
      ],
    );
  }
}
