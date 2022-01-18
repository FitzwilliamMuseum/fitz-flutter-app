import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'error.dart';
import 'home.dart';

import 'dart:async';


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

  Future<Timer> loadData() async => Timer(const Duration(seconds: 3), onDoneLoading);

  onDoneLoading() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favorites");

    if (list == null) {
      prefs.setStringList("favorites", []);
    }

    var result = await Connectivity().checkConnectivity();
    // ignore: missing_enum_constant_in_switch
    switch (result) {
      case ConnectivityResult.wifi:
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => HomePage())
        );
        break;
      case ConnectivityResult.mobile:
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => HomePage())
        );
        break;
      case ConnectivityResult.none:
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => const ErrorPage())
        );
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
      body:  Container(
        constraints: const BoxConstraints.expand(),
        decoration:  BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: const AssetImage('assets/Portico.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.6), BlendMode.dstATop)
            )
        ),
        child: Image.asset(
          'assets/Fitz_logo_white.png',
          height: 200,
          width:  200,
        ),
        alignment: Alignment.center,
      ),
    );
  }
}