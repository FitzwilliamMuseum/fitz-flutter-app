import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'gallery.dart';
import 'utilities/icons.dart';
import 'models/galleries_model.dart';

class GalleriesPage extends ConsumerStatefulWidget {
  const GalleriesPage({Key? key}) : super(key: key);

  @override
  GalleriesPageState createState() => GalleriesPageState();
}

class GalleriesPageState extends ConsumerState<GalleriesPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  Widget _newsItems() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
      data: (results) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _GalleryCard(result: result);
        },
      ),
      error: (e, st) =>
          Text(e.toString(), style: Theme.of(context).textTheme.headline5),
      loading: () => errorLoadingRosette(),
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
              const _GalleryHeadline(),
              _newsItems(),
              rosettes(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryHeadline extends StatelessWidget {
  const _GalleryHeadline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Discover our galleries",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)))
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({Key? key, required this.result}) : super(key: key);
  final dynamic result;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
          leading: Image.network(result.image),
          title: Text(result.title),
          trailing: const Icon(Icons.more_vert),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GalleryPage(id: result.id.toString())
              ),
            );
        },
      )
    );
  }
}
