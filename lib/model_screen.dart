import 'providers/3d_models.dart';
import 'models/3d_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utilities/icons.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class DetailsPage extends ConsumerWidget {
  const DetailsPage({Key? key, required this.movieId}) : super(key: key);

  final int movieId;

  @override
  Widget build(context, ref) {
    final modelProvider = ref.watch(modelDetailsProvider(movieId));
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: floatingHomeButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      body: modelProvider.when(
        data: (ThreeDModel? model) {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  Stack(children: <Widget>[
                    errorLoadingRosette(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black,
                      child: ModelViewer(
                        backgroundColor: Colors.black,
                        src: model!.glb,
                        alt: model.title,
                        autoRotate: true,
                        autoRotateDelay: 100,
                        cameraControls: true,
                      ),
                    ),
                    backIcon(context),
                    aboutIcon(context),
                    Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30,60,30,0),
                          child: Text(
                      model.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                        )),
                  ]),
                ],
              ),
            ),
          );
        },
        loading: () => Center(
          child: errorLoadingRosette(),
        ),
        error: (_, __) {
          return const Center(
              child: Text("An Error occurred, try again later."));
        },
      ),
    );
  }
}
