import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({Key? key}) : super(key: key);

  @override
  _ModelsPageState createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff00BCD1),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.museum_outlined),
        tooltip: "Go Home",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: const BottomAppBar(
        color: Colors.black,
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ModelViewer(
                  backgroundColor: Colors.black12,
                  // src: "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
                  src: 'https://fitz-cms-images.s3.eu-west-2.amazonaws.com/scene.glb',
                  alt: "A 3D model of a grave marker",
                  ar: false,
                  autoRotate: true,
                  cameraControls: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
