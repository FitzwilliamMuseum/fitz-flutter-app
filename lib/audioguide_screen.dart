import 'package:fitz_museum_app/audioguide_list_screen.dart';
import 'package:fitz_museum_app/utilities/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audioguide_chooser.dart';
import 'audioguide_slider_screen.dart';

class AudioGuide extends StatefulWidget {
  const AudioGuide({Key? key}) : super(key: key);

  @override
  _AudioGuideState createState() => _AudioGuideState();
}

class _AudioGuideState extends State<AudioGuide> {
  // text controller
  final TextEditingController _myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: floatingHomeButton(context),
        resizeToAvoidBottomInset: false,
        body: Stack(children: <Widget>[
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                    image: AssetImage('assets/Portico.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Color.fromRGBO(117, 117, 117, 0.4),
                        BlendMode.modulate))),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(children: <Widget>[
                  backIcon(context),
                  aboutIcon(context),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 100, 20, 0),
                      child: Icon(
                        IconData(0xf0f0, fontFamily: 'MaterialIcons'),
                        size: 60,
                      ),
                    ),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 160, 20, 0),
                      child: Text('Choose an audio stop',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 200, 20, 0),
                    child: Container(
                      height: 100,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                                hintText: "Start with 101 to try this out",
                                hintStyle: TextStyle(fontSize: 16, color: Colors.black)
                            ),
                            controller: _myController,
                            textAlign: TextAlign.center,
                            showCursor: false,
                            style: const TextStyle(
                                fontSize: 40, color: Colors.black),
                            keyboardType: TextInputType.none,
                            maxLength: 4,
                            maxLengthEnforcement: MaxLengthEnforcement
                                .truncateAfterCompositionEnds,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            // use the validator to return an error string (or null) based on the input text
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Can\'t be empty. 4 digits only.';
                              }
                              if (text.length > 4) {
                                return 'Too long';
                              }
                              return null;
                            },
                          ),
                        )),
                      ),
                    ),
                  ),
                  // implement the custom NumPad
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 300, 20, 0),
                    child: SizedBox(
                      height: 375,
                      child: NumPad(
                        buttonSize: 65,
                        buttonColor: const Color(0xd5441318),
                        iconColor: Colors.white,
                        controller: _myController,
                        delete: () {
                          _myController.text = _myController.text
                              .substring(0, _myController.text.length - 1);
                        },
                        // do something with the input numbers
                        onSubmit: () {
                          debugPrint('Your code: ${_myController.text}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AudioGuideSliderPage(
                                    id: _myController.text)),
                          );
                        },
                      ),
                    ),
                  ),
                ]),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AudioGuideListPage()),
                    );
                  },
                  child: const Text('Or see all stops'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                pineapples()
              ],
            ),
          ),
        ]));
  }
}
