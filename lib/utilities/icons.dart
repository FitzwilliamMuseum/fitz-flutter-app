import 'package:flutter/material.dart';


rosette() {
  return Image.asset('assets/rosette.png', height: 100, width: 100);
}

pineapple() {
  return Image.asset('assets/pineapple.jpg', height: 50, width: 50);
}

fitzlogo() {
  return Image.asset('assets/Fitz_logo_white.png', height: 150, width: 150);
}
pineapples() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      pineapple(),
      pineapple(),
      pineapple(),
      pineapple()
    ],
  );
}