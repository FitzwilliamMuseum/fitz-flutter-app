import 'package:fitz_museum_app/utilities/icons.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/news_model.dart';
import 'story.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends ConsumerState<NewsPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  Widget newsItems() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
        data: (results) => ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return _NewsCard(result: result);
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
                homeRosette()
              ]),
              const _NewsHeadlineText(),
              newsItems(),
              pineapples(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsHeadlineText extends StatelessWidget {
  const _NewsHeadlineText ({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Latest News",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)))
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({Key? key, required this.result}) : super(key: key);
  final dynamic result;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
          leading: Image.network(result.image),
          title: Text(result.title),
          subtitle: Text(result.date),
          trailing: const Icon(Icons.more_vert),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StoryPage(id: result.id.toString())),
            );
          },
        ));
  }
}