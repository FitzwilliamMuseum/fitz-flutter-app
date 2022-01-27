import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:card_swiper/card_swiper.dart';

class Actions {
  Actions(
      {required this.title,
      required this.image,
      required this.route,
      required this.subtitle,
      required this.icon});

  final String title;
  final String image;
  final String route;
  final String subtitle;
  final String icon;

  factory Actions.fromJson(Map<String, dynamic> data) {
    return Actions(
        subtitle: data['subtitle'].toString(),
        title: data['title'],
        image: data['image']['data']['thumbnails'][2]['url'],
        route: data['route'],
        icon: data['icon']);
  }
}

Future<List<Actions>> fetch(http.Client client) async {
  final response = await client.get(Uri.parse(
      'https://content.fitz.ms/fitz-website/items/app_action_list?fields=*.*&sort=-id'));
  return compute(parseActions, utf8.decode(response.bodyBytes));
}

List<Actions> parseActions(String responseBody) {
  final parsed = jsonDecode(responseBody);
  final resultsJson = parsed['data'] as List<dynamic>;
  return resultsJson.map<Actions>((json) => Actions.fromJson(json)).toList();
}

class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}

void main() => runApp(const ExploreActionsPage());

class ExploreActionsPage extends StatelessWidget {
  const ExploreActionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Actions>>(
        future: fetch(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return SwiperList(actions: snapshot.data!);
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
  const SwiperList({Key? key, required this.actions}) : super(key: key);

  final List<Actions> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      height: 300,
      width: 500,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            final result = actions[index];
            return Card(
                color: Colors.black,
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(20.0),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, result.route.toString());
                    },
                    child: Stack(clipBehavior: Clip.none, children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: Image.network(
                          result.image,
                          fit: BoxFit.cover,
                          colorBlendMode: BlendMode.modulate,
                          color: const Color.fromRGBO(255,255,255, 0.7),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 30, 20, 20),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Image.asset(
                              'assets/pineApple.png',
                              width: 60,
                              height: 60,
                            ),
                          )),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 160, 0, 0),
                            child: Text(result.title + '\n' + result.subtitle,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 20.0, color: Colors.white)),
                          ),

                        ],
                      )
                    ])));
          },
          loop: true,
          itemCount: actions.length,
          control: const SwiperControl(color: Colors.purple),
          viewportFraction: 0.8,
          scale: 0.9,
          layout: SwiperLayout.STACK,
          itemWidth: 500,
          itemHeight: 400,
        ),
      ),
    );
  }
}
