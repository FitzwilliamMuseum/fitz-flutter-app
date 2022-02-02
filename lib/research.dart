import 'package:fitz_museum_app/utilities/icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/research_model.dart';
import 'research_project.dart';
import 'utilities/icons.dart';

class ResearchPage extends ConsumerStatefulWidget {
  const ResearchPage({Key? key}) : super(key: key);

  @override
  ResearchPageState createState() => ResearchPageState();
}

class ResearchPageState extends ConsumerState<ResearchPage> {
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
                    MaterialPageRoute(builder: (context) =>  ProjectPage(id: result.id.toString())),
                  );
                },
              ));
        },
      ),
      error: (e, st) =>
          Text(e.toString(), style: Theme.of(context).textTheme.headline5),
      loading: () => SizedBox(
        height: 400,
        width: 400,
        child: Image.asset('assets/rosetteRotate.gif', height: 100, width: 100),
      ),
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
              _ResearchTitle(),
              newsItems(),
              pineapples(),
            ],
          ),
        ),
      ),
    );
  }
}



class _ResearchTitle extends StatelessWidget {
  const _ResearchTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text("Our research projects",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: Colors.black)
              )
          )
        ],
      ),
    );
  }
}

