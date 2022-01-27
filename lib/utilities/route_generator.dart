import 'package:flutter/material.dart';
import '../home.dart';
import '../podcasts.dart';


Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case 'home':
      return MaterialPageRoute(builder: (_) => HomePage());
    case 'podcasts':
      return MaterialPageRoute(builder: (_) => const PodcastsPage());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
