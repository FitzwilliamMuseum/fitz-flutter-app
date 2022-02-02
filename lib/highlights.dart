import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utilities/icons.dart';
import 'highlight.dart';
import 'models/highlights_model.dart';

class HighlightsPage extends ConsumerStatefulWidget {
  const HighlightsPage({Key? key}) : super(key: key);

  @override
  HighlightsPageState createState() => HighlightsPageState();
}

class HighlightsPageState extends ConsumerState<HighlightsPage> {
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
            trailing: const Icon(Icons.more_vert),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HighlightPage(id: result.id.toString())),
              );
            },
          ));
        },
      ),
      error: (e, st) =>
          Text(e.toString(), style: Theme.of(context).textTheme.headline5),
      loading: () => errorLoadingRosette()
    );
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
            child: Text("Highlight objects",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30.0, color: Colors.black)))
      ],
    ),
  );
}
