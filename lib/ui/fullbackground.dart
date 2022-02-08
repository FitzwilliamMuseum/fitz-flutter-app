import 'package:flutter/material.dart';
Widget fullbackground(){
  return Container(
    constraints: const BoxConstraints.expand(),
    decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
            image: const AssetImage('assets/Portico.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.6), BlendMode.dstATop)
        )
    ),
    child: Image.asset(
      'assets/Fitz_logo_white.png',
      height: 200,
      width: 200,
    ),
    alignment: Alignment.center,
  );
}