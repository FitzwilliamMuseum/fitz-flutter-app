import 'dart:convert';
import 'package:fitz_museum_app/360_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'utilities/fullscreen.dart';
import 'utilities/icons.dart';
import 'utilities/string_replace.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
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
        tooltip: "Go home",
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

  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/galleries?fields=gallery_name,id,slug,gallery_description,gallery_status,hero_image.*,image_360_pano.*&sort=id&filter[id][eq]=" +
            id;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
  }



  Widget builder(id) {
    return FutureBuilder(
        future: fetchData(http.Client(), id),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
           const _LoadingIcon();
          }
          if (snapshot.hasData) {
            final data = jsonDecode(snapshot.data.toString());

            final gallery = data['data'][0];

            return Column(
              children: <Widget>[
                _GalleryTitle(gallery: gallery),
                _HeaderImage(gallery: gallery),
                _ThreeSixtyButton(gallery: gallery),
                _GalleryDescription(gallery: gallery),
                _Chip(gallery: gallery),
                pineappleSingle(),
              ],
            );
          } else {
            return Container();
          }
        });
  }

}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({Key? key, required this.gallery}) : super(key: key);
  final dynamic gallery;

  @override
  Widget build(BuildContext context) {
    if (gallery['hero_image'] != null) {
      return ImageFullScreenWrapperWidget(
        child: Image.network(
          gallery['hero_image']['data']['url'],
        ),
        dark: true,
      );
    } else {
      return Container();
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({Key? key, required this.gallery})
      : super(key: key);
  final dynamic gallery;
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(gallery["gallery_status"][0]),
    );
  }
}


class _GalleryDescription extends StatelessWidget {
  const _GalleryDescription({Key? key, required this.gallery})
      : super(key: key);
  final dynamic gallery;

  @override
  Widget build(BuildContext context) {
    if (gallery["gallery_description"] != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: MarkdownBody(
          data: removeAllHtmlTags(gallery["gallery_description"]),
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class _GalleryTitle extends StatelessWidget {
  const _GalleryTitle({Key? key, required this.gallery})
      : super(key: key);
  final dynamic gallery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: Align(
              alignment: Alignment.center,
              child: Text(gallery["gallery_name"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20.0, color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}

class _LoadingIcon extends StatelessWidget {
  const _LoadingIcon({Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: SizedBox(
            height: 100,
            width: 100,
            child: Image.asset('assets/rosetteRotate.gif',
                height: 150, width: 150)),
      ),
    );
  }
}

class _ThreeSixtyButton extends StatelessWidget{
  const _ThreeSixtyButton({Key? key, required this.gallery})
      : super(key: key);
  final dynamic gallery;

  @override
  Widget build(BuildContext context) {
    if (gallery['image_360_pano'] != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          gallery_360_page(id: gallery['id'].toString())),
                );
              },
              child: const Text('View in 360'),
              style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}