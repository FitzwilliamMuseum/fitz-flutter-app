import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'utilities/icons.dart';
import 'models/covid_model.dart';
import 'utilities/string_replace.dart';

class CovidPage extends ConsumerStatefulWidget {
  const CovidPage({Key? key}) : super(key: key);
  @override
  CovidPageState createState() => CovidPageState();
}

class CovidPageState extends ConsumerState<CovidPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  Widget builder() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
      data: (results) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _BodyText(result: result);
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
              Stack(
                children: <Widget>[
                  portico(context),
                  backIcon(context),
                  aboutIcon(context),
                  homeLogo(),
                  homeRosette()
                ],
              ),
              const _HeadlineText(),
              const Icon(
                   IconData(0xe199, fontFamily: 'MaterialIcons'),
                  color: Colors.deepPurple,size: 90.0

              ),
              builder(),
              pineapples(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeadlineText extends StatelessWidget {
  const _HeadlineText({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Covid 19 latest measures",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black))
          )
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText({ Key? key, required this.result }) : super(key: key);
  final dynamic result;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20,0,20,0),
      child: MarkdownBody(
        data: removeAllHtmlTags(result.text),
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }
}