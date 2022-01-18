import 'package:flutter/material.dart';
import 'package:fitz_museum_app/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: FitzApp()));
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
    );
  }
}

