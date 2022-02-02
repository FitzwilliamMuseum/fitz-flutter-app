import 'dart:convert' show jsonDecode, utf8;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:panorama/panorama.dart';

import 'home.dart';

class gallery_360_page extends StatefulWidget {
  const gallery_360_page({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _gallery_360_pageState createState() => _gallery_360_pageState();
}

class _gallery_360_pageState extends State<gallery_360_page> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/galleries?fields=gallery_name,id,slug,gallery_status,hero_image.*,image_360_pano.*&sort=id&filter[id][eq]=" +
            id;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
  }

  builder(id) {
    return FutureBuilder(
      future: fetchData(http.Client(), id),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
        final data = jsonDecode(snapshot.data.toString());
        final gallery = data['data'][0];
        final dynamic panorama;
        if (gallery['image_360_pano'] != '') {
          panorama = SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Panorama(
                child: Image.network(
                    gallery['image_360_pano']['data']['url'],
                )
            ),
          );
        } else {
          panorama = const SizedBox.shrink();
        }
        return Column(
          children: <Widget>[
            panorama,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff79a58d),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.museum_outlined),
        tooltip: "Go Home",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Stack(children: <Widget>[
                builder(widget.id),
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
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
