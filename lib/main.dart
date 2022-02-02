import 'package:fitz_museum_app/highlights.dart';
import 'package:flutter/material.dart';
import 'package:fitz_museum_app/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'podcasts.dart';
import 'news.dart';
import 'random.dart';
import 'highlights.dart';
import 'covid.dart';
import 'exhibitions.dart';
import 'galleries.dart';
import 'research.dart';
import 'models.dart';
import 'augmented.dart';
void main() {
  runApp(const ProviderScope(child: FitzApp()));
}

class FitzApp extends StatelessWidget {
  const FitzApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Fitzwilliam Museum',
      theme: ThemeData(
        iconTheme: const IconThemeData(
            color: Colors.white
        ),
        primarySwatch: Colors.grey,
          scaffoldBackgroundColor: Colors.white
      ),
      home: const SplashScreen(),
      initialRoute: 'home',
      routes: {
        'podcasts': (context) => const PodcastsPage(),
        'news': (context) => const NewsPage(),
        'random': (context) => const RandomPage(),
        'highlights':  (context) => const HighlightsPage(),
        'covid': (context) => const CovidPage(),
        'exhibitions': (context) => const ExhibitionsPage(),
        'galleries': (context) => const GalleriesPage(),
        'research': (context) => const ResearchPage(),
        '3d': (context) => const ModelsPage(),
        'augmented':(context) => ObjectsOnPlanesWidget(),
      },
    );
  }
}

