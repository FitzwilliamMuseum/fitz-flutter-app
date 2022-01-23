import 'dart:convert';
import 'package:fitz_museum_app/exhibition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:card_swiper/card_swiper.dart';

class Exhibitions {
  Exhibitions(
      {required this.title,
      required this.image,
      required this.url,
      required this.id});

  final String title;
  final String image;
  final String url;
  final String id;

  factory Exhibitions.fromJson(Map<String, dynamic> data) {
    return Exhibitions(
        id: data['id'].toString(),
        title: data['exhibition_title'],
        image: data['hero_image']['data']['thumbnails'][2]['url'],
        url: data['slug']);
  }
}

Future<List<Exhibitions>> fetch(http.Client client) async {
  final response = await client.get(Uri.parse(
      'https://content.fitz.ms/fitz-website/items/exhibitions?fields=exhibition_title,id,slug,exhibition_narrative,hero_image.*,type,exhibition_status&sort=&sort=-exhibition_end_date&limit=12'));
  // Use the compute function to run parsePhotos in a separate isolate.
  return compute(parseExhibits, response.body);
}

// A function that converts a response body into a List<Photo>.
List<Exhibitions> parseExhibits(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final resultsJson = parsed['data'] as List<dynamic>;
  return resultsJson
      .map<Exhibitions>((json) => Exhibitions.fromJson(json))
      .toList();
}

void main() => runApp(ExPage());

class ExPage extends StatelessWidget {
  const ExPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Exhibitions>>(
        future: fetch(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return SwiperList(photos: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}


class SwiperList extends StatelessWidget {
  const SwiperList({Key? key, required this.photos}) : super(key: key);

  final List<Exhibitions> photos;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(color: Colors.blue),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 60),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            final result = photos[index];
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ExhibitionPage(id: result.id.toString())),
                  );
                }, // Image tapped
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(result.image),
                  ),
                )
              ),
            );
          },
          loop: true,
          itemCount: photos.length,
          control: SwiperControl(),
          viewportFraction: 0.8,
          scale: 0.9,
          layout: SwiperLayout.STACK,
          itemWidth: 300,
          itemHeight: 400,
          pagination: const SwiperPagination(
            // margin: EdgeInsets.all(15.0),
            builder: DotSwiperPaginationBuilder(
                color: Colors.white, activeColor: Colors.red),
          ),
        ),
      ),
    );
  }
}
