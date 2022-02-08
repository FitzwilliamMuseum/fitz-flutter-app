import 'package:fitz_museum_app/utilities/icons.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/3d_models.dart';

import 'model_screen.dart';

class ThreeDimensionalModelsPage extends ConsumerStatefulWidget {
  const ThreeDimensionalModelsPage({Key? key}) : super(key: key);

  @override
  _ThreeDimensionalModelsPageState createState() =>
      _ThreeDimensionalModelsPageState();
}

class _ThreeDimensionalModelsPageState
    extends ConsumerState<ThreeDimensionalModelsPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  modelsList() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
        data: (results) => GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisExtent: 280,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2),
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Card(
                    color: Colors.black,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.view_in_ar, color: Colors.white),
                          title: Text(
                            result.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                      modelID: int.parse(result.id))),
                            );
                          }, // Image tapped
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Image.network(
                              result.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
        error: (e, st) =>
            Text(e.toString(), style: Theme.of(context).textTheme.headline5),
        loading: () => errorLoadingRosette());
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
              Stack(children: <Widget>[
                portico(context),
                backIcon(context),
                aboutIcon(context),
                homeLogo(),
                homeRosette(),
                // favoritesIcon(context),
              ]),
              const _HeadlineText(),
              modelsList(),
              pineapples(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeadlineText extends StatelessWidget {
  const _HeadlineText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Discover 3d models",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)))
        ],
      ),
    );
  }
}
