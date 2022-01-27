import 'dart:convert';

import 'package:fitz_museum_app/exhibition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:card_swiper/card_swiper.dart';
import 'package:intl/intl.dart';


class Exhibitions {
  Exhibitions(
      {required this.title,
      required this.image,
      required this.url,
      required this.id,
      this.startDate,
      this.endDate});

  final String title;
  final String image;
  final String url;
  final String id;
  final DateTime? startDate;
  final DateTime? endDate;

  factory Exhibitions.fromJson(Map<String, dynamic> data) {
    return Exhibitions(
        id: data['id'].toString(),
        title: data['exhibition_title'],
        image: data['hero_image']['data']['thumbnails'][2]['url'],
        url: data['slug'],
        startDate: DateTime.tryParse(data['exhibition_start_date']),
        endDate: DateTime.tryParse(data['exhibition_end_date']));
  }
}

Future<List<Exhibitions>> fetch(http.Client client) async {
  final response = await client.get(Uri.parse(
      'https://content.fitz.ms/fitz-website/items/exhibitions?fields=exhibition_title,id,slug,exhibition_narrative,exhibition_start_date,exhibition_end_date,hero_image.*,type,exhibition_status&sort=&sort=-exhibition_end_date&limit=12'));
  return compute(parseExhibits, utf8.decode(response.bodyBytes));
}

List<Exhibitions> parseExhibits(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final resultsJson = parsed['data'] as List<dynamic>;
  return resultsJson
      .map<Exhibitions>((json) => Exhibitions.fromJson(json))
      .toList();
}

void main() => runApp(const ExPage());

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
            return SwiperList(exhibits: snapshot.data!);
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
  const SwiperList({Key? key, required this.exhibits}) : super(key: key);

  final List<Exhibitions> exhibits;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            final result = exhibits[index];
            final dates;
            if (result.startDate != null && result.endDate != null) {
              dates = DateFormat.yMMMMd('en_US').format(result.startDate!) +
                  ' - ' +
                  DateFormat.yMMMMd('en_US').format(result.endDate!);
            } else {
              dates = '';
            }
            return Card(
                color: Colors.black,
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(20.0),
                child: Stack(clipBehavior: Clip.none, children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 400,
                    child: Image.network(
                      "https://fitz-cms-images.s3.eu-west-2.amazonaws.com/fitzwilliam-museum-main-entrance-2018_3-1.jpg",
                      fit: BoxFit.fill,
                      colorBlendMode: BlendMode.modulate,
                      color: const Color.fromRGBO(117, 117, 117, 0.9),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(result.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16.0, color: Colors.white)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                            child: Text(dates,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13.0, color: Colors.white)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ExhibitionPage(
                                          id: result.id.toString())),
                                );
                              }, // Image tapped
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 200,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          NetworkImage(result.image),
                                    ),
                                  ),
                                  // Stack(children: <Widget>[
                                  //   Positioned(
                                  //     top: 90.0,
                                  //     left: 40,
                                  //     child: Container(
                                  //       padding: const EdgeInsets.fromLTRB(
                                  //           0, 0, 0, 0),
                                  //       child: Positioned(
                                  //         top: 200.0,
                                  //         child: Image.asset(
                                  //             'assets/pineApple.png',
                                  //             width: 75,
                                  //             height: 75),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ]
                                  // ),
                                ],
                              ),
                              //
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]));
          },
          loop: true,
          itemCount: exhibits.length,
          control: const SwiperControl(color: Colors.purple),
          viewportFraction: 0.8,
          scale: 0.9,
          // layout: SwiperLayout.STACK,
          itemWidth: 300,
          itemHeight: 500,
        ),
      ),
    );
  }
}
