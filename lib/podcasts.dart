import 'package:fitz_museum_app/utilities/icons.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'podcast_episode.dart';
import 'models/podcasts_model.dart';

class PodcastsPage extends ConsumerStatefulWidget {
  const PodcastsPage({Key? key}) : super(key: key);

  @override
  PodcastsPageState createState() => PodcastsPageState();
}

class PodcastsPageState extends ConsumerState<PodcastsPage> {
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
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  EpisodePage(id: result.id.toString())),
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
              Stack(children: <Widget>[
                portico(context),
                backIcon(context),
                aboutIcon(context),
                homeLogo(),
                homeRosette(),
                // favoritesIcon(context),
              ]),
              const _PodcastHeadlineText(),
              newsItems(),
              pineapples(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodcastHeadlineText extends StatelessWidget {
  const _PodcastHeadlineText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Discover audio wonders",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)
              )
          )
        ],
      ),
    );
  }
}
