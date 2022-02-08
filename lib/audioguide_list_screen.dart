import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utilities/icons.dart';
import 'audioguide_slider_screen.dart';
import 'models/audioguide_model.dart';

class AudioGuideListPage extends ConsumerStatefulWidget {
  const AudioGuideListPage({Key? key}) : super(key: key);

  @override
  AudioGuideListPageState createState() => AudioGuideListPageState();
}

class AudioGuideListPageState extends ConsumerState<AudioGuideListPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  newsItems() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
        data: (results) => ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Card(
                    child: ListTile(
                  leading: Image.network(result.image),
                  title: Text(result.title),
                  subtitle: Text(result.id),
                  trailing: const Icon(Icons.more_vert),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              AudioGuideSliderPage(id: result.id.toString())),
                    );
                  },
                ));
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
              fitzHomeBanner(context),
              newsHeadlineText(),
              newsItems(),
              pineapples(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget newsHeadlineText() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
            child: Text("All stops",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30.0, color: Colors.black)))
      ],
    ),
  );
}
