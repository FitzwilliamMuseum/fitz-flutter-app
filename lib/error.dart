import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fitz_museum_app/splash_screen.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}


class _ErrorPageState extends State<ErrorPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.dangerous, size: 50, color: Colors.red),
            const Text("No Internet Connection!"),
            const Text("To use this you will need an internet connection.", textAlign: TextAlign.center),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red)
              ),
              onPressed: () {
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) => const SplashScreen())
                );
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}