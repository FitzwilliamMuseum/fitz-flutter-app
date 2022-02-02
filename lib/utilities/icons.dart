import 'package:flutter/material.dart';

import '../home.dart';
import '../about.dart';
import '../favorites.dart';

pineapples() {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          4, (index) => Container(child: pineappleSingle())),
    ),
  );
}

rosetteSingle() {
  return Image.asset('assets/rosette.png', height: 100, width: 100);
}


pineappleSingle() {
  return Image.asset('assets/pineapple.jpg', height: 50, width: 50);
}

fitzLogo() {
  return Image.asset('assets/Fitz_logo_white.png', height: 150, width: 150);
}


rosettes() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children:
    List.generate(3, (index) => Container(child: rosetteSingle())),
  );
}

errorLoadingRosette() {
  return SizedBox(
    height: 200,
    width: 200,
    child: Image.asset('assets/rosetteRotate.gif', height: 75, width: 75),
  );
}


floatingHomeButton(context) {
  return FloatingActionButton(
    child: const Icon(Icons.museum_outlined),
    tooltip: "Go Home",
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    },
  );
}


portico(context) {
  return SizedBox(
    width: MediaQuery
        .of(context)
        .size
        .width,
    height: 350,
    child: Image.asset("assets/Portico.jpg",
        fit: BoxFit.fill,
        color: const Color.fromRGBO(117, 117, 117, 0.9),
        colorBlendMode: BlendMode.modulate),
  );
}

backIcon(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 50, 0),
        child: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            iconSize: 30,
            color: Colors.white,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ));
  }

homeIcon(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
        child: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            iconSize: 30,
            color: Colors.white,
            icon: const Icon(Icons.home),
            tooltip: "Go to app home page",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ));
  }


aboutIcon(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 10, 20),
        child: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            iconSize: 30,
            color: Colors.white,
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ));
  }

favoritesIcon(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 40, 20),
        child: Align(
          alignment: Alignment.topRight,
          child: IconButton(
            iconSize: 30,
            color: Colors.white,
            icon: const Icon(Icons.favorite),
            tooltip: "View your selected favourite objects",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ));
  }

homeLogo() {
    return  Padding(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: Align(alignment: Alignment.bottomCenter, child: fitzLogo()),
    );
  }

homeRosette() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 230, 0, 0),
      child: Align(alignment: Alignment.bottomCenter, child: rosetteSingle()),
    );
  }


footerPineapples() {
    return  SizedBox(width: 400, height: 100, child: pineapples());
  }

fitzHomeBanner(context) {
    return Stack(
      children: <Widget>[
        portico(context),
        backIcon(context),
        aboutIcon(context),
        homeLogo(),
        homeRosette()
      ],
    );
  }
