import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'exhibition.dart';
import 'models/exhibition_model.dart';
import 'utilities/icons.dart';

class ExhibitionsPage extends ConsumerStatefulWidget {
  const ExhibitionsPage({Key? key}) : super(key: key);

  @override
  ExhibitionsPageState createState() => ExhibitionsPageState();
}

class ExhibitionsPageState extends ConsumerState<ExhibitionsPage> {
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
          return _ExhibitionCard(result: result);
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
              const _Exhibit(),
              newsItems(),
              pineapples(),
            ],

          ),
        ),
      ),
    );
  }
}

class _ExhibitionCard extends StatelessWidget {
  const _ExhibitionCard({
    Key? key, required this.result
  }) : super(key: key);
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
                  builder: (context) => ExhibitionPage(id: result.id)),
            );
          },
        ));
  }
}

class _Exhibit extends StatelessWidget {
  const _Exhibit({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Our current exhibitions",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)))
        ],
      ),
    );
  }
}

class _NewsItems extends ConsumerState<ExhibitionsPage> {
  @override
  Widget build(BuildContext context) {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
        data: (results) => ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _ExhibitionCard(result: result);
          },
        ),
        error: (e, st) =>
            Text(e.toString(), style: Theme.of(context).textTheme.headline5),
        loading: () => errorLoadingRosette()
    );

  }
}