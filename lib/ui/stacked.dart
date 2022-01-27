
import 'package:flutter/material.dart';

class StyleCard extends StatelessWidget {
  final Image image;
  final String title;
  final String description;

  const StyleCard({
    Key? key,
    required this.image,
    required this.title,
    required this.description
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width*0.7,
              height: MediaQuery.of(context).size.width*0.65,
              child: image,
            ),
            const SizedBox(height: 5,),
            Text(
              title,
              style: const TextStyle(color: Colors.pinkAccent,fontSize: 22,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10,),
            Text(
              description,
              style: const TextStyle(color: Colors.black),textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }
}