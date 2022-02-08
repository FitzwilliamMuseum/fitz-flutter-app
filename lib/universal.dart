import 'dart:io';
import 'package:fitz_museum_app/utilities/icons.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UniversalViewer extends StatefulWidget {
  const UniversalViewer({Key? key}) : super(key: key);

  @override
  State<UniversalViewer> createState() => _UniversalViewerState();
}

class _UniversalViewerState extends State<UniversalViewer> {
  @override
  void initState() {
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: floatingHomeButton(context),
        resizeToAvoidBottomInset: false,
        body: Container(
          height: double.infinity,
          child: Stack(
            children: [
              const Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 40),
                  child: WebView(
                    initialUrl:
                        'https://data.fitzmuseum.cam.ac.uk/id/image/flutter/iiif/media-10607#?c=&m=&cv=',
                    javascriptMode: JavascriptMode.unrestricted,
                  )),
              backIcon(context),
              aboutIcon(context)
            ],
          ),
        ));
  }
}
