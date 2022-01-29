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
                          builder: (context) => const HighlightPage(id: '19')),
                    );
                  },
                  child: Image.network(
                    "https://content.fitz.ms/fitz-website/assets/GR.1-1835_LRG.jpg",
                    fit: BoxFit.fill,
                  ),
                ),
              ]),
            )),
      ],
    );
  }
}
