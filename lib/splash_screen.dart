import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'error.dart';
import 'home.dart';
import 'dart:async';
import 'ui/fullbackground.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    loadData();
  }

  Future<Timer> loadData() async =>
      Timer(const Duration(seconds: 3), onDoneLoading);

  onDoneLoading() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    if (list == null) {
      prefs.setStringList("favorites", []);
    }

    var result = await Connectivity().checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
      // case ConnectivityResult.ethernet:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case ConnectivityResult.mobile:
      // case ConnectivityResult.bluetooth:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case ConnectivityResult.none:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ErrorPage()));
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: fullbackground()
    );
  }
}
