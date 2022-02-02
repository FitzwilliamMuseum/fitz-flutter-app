import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utilities/fullscreen.dart';
import 'utilities/icons.dart';
import 'models/random_object.dart';

class RandomPage extends ConsumerStatefulWidget {
  const RandomPage({Key? key}) : super(key: key);

  @override
  RandomPageState createState() => RandomPageState();
}

class RandomPageState extends ConsumerState<RandomPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(searchResultsProvider);
  }

  record() {
    final searchResultsData = ref.watch(searchResultsProvider);
    return searchResultsData.when(
      data: (results) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          const contentUrl = 'https://data.fitzmuseum.cam.ac.uk/imagestore/';
          final title = result.fullTitle;
          final maker = result.maker;
          final department = result.department;
          final accession = result.accession;

          return Column(
            children: <Widget>[
              fullscreen(Image.network(
                contentUrl + result.image,
              )),
              objectTitle(title),
              accessionNumber(accession),
              objectMaker(maker),
              descriptiveText(result),
              holdingDepartment(department),
              collectionButton(result),
            ],
          );
        },
      ),
      error: (e, st) =>
          Text(e.toString(), style: Theme.of(context).textTheme.headline5),
      loading: () => errorLoadingRosette()
    );
  }
  Widget objectTitle(title){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 30.0, color: Colors.black)),
          )
        ],
      ),
    );
  }

  Widget objectMaker(maker){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Text('Made by: ' + maker!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20.0, color: Colors.purple)),
          )
        ],
      ),
    );
  }

  Widget holdingDepartment(department){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Text('In the collection of ' + department!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16.0, color: Colors.black)),
          )
        ],
      ),
    );
  }
  Widget descriptiveText(result){
    if(result.description != '') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(result.description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16.0, color: Colors.black)),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }
  Widget accessionNumber(accession){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(accession,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 30.0, color: Colors.black)),
          )
        ],
      ),
    );
  }
  Widget collectionButton(result){
    _launchURL() async {
      if (await canLaunch(result.url)) {
        await launch(result.url);
      } else {
        throw 'Could not launch $result.url';
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _launchURL,
            child: const Text('View online'),
            style: ElevatedButton.styleFrom(
                primary: Colors.black,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 10),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget fullscreen(leading){
    return ImageFullScreenWrapperWidget(
      child: leading,
      dark: true,
    );
  }

  Widget departmentText(department){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
      child: Row(
        children: [
          Expanded(
            child: Text('In the collection of ' + department!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16.0, color: Colors.black)),
          )
        ],
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
              Stack(children: <Widget>[

                record(),
                backIcon(context),
                aboutIcon(context),
              ]),
              pineappleSingle()
            ],
          ),
        ),
      ),
    );
  }
}

Widget maker(maker){
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 6, 0, 0),
    child: Row(
      children: [
        Expanded(
          child: Text('Made by: ' + maker!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20.0, color: Colors.purple)),
        )
      ],
    ),
  );
}
