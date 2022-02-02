import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utilities/icons.dart';
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
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingHomeButton(context),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              fitzHomeBanner(context),
              const _ConnectivityTextTitle(),
              const _ConnectivityTextBody(),
              const _ConnectivityRetryButton()
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectivityRetryButton extends StatelessWidget {
  const _ConnectivityRetryButton ({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()));
              },
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectivityTextBody extends StatelessWidget {
  const _ConnectivityTextBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
            child: Text(
                "To use this app, you will need an internet connection.",
                textAlign: TextAlign.center,
                style:
                TextStyle(fontSize: 16.0, color: Colors.black)),
          )
        ],
      ),
    );
  }
}

class _ConnectivityTextTitle extends StatelessWidget {
  const _ConnectivityTextTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
            child: Text("You have no connection to the internet",
                textAlign: TextAlign.center,
                style:
                TextStyle(fontSize: 20.0, color: Colors.black)),
          )
        ],
      ),
    );
  }
}