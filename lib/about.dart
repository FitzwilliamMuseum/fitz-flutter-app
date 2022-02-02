import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utilities/icons.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
              const _AboutTextTitle(),
              const _AboutTextBody(),
              footerPineapples(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutTextBody extends StatelessWidget {
  const _AboutTextBody({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Flexible(
              child: Text(
                "This is an experimental app to showcase the Fitzwilliam Museum's collection of objects and rich media. "
                    "\n\nIt was built by Daniel Pett, using Flutter.\n\nVersion 1.0",
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }
}

class _AboutTextTitle extends StatelessWidget {
  const _AboutTextTitle({ Key? key }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: const TextSpan(
              text: 'About this app',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }
}