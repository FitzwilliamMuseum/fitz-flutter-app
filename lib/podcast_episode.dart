import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_session/audio_session.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utilities/common.dart';
import 'utilities/icons.dart';
import 'utilities/string_replace.dart';

class EpisodePage extends StatefulWidget {
  const EpisodePage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _EpisodePageState createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage> with WidgetsBindingObserver {
  final _player = AudioPlayer();

  Future<void> _init(snapshot) async {
    final data = jsonDecode(snapshot.data.toString());
    // Inform the operating system of our app's audio attributes etc.
    // We pick a reasonable default for an app that plays speech.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAudioSource(
          AudioSource.uri(Uri.parse(data['data'][0]['mp3_id'])));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }



  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/podcast_archive?fields=*.*.*.*&limit=1&filter[id][eq]=" +
            id;
    final response = await client.get(Uri.parse(uri));
    if (response.statusCode == 200) {
      return (utf8.decode(response.bodyBytes));
    }
  }

  builder(id) {
    return FutureBuilder(
      future: fetchData(http.Client(), id),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return errorLoadingRosette();
        }
        final data = jsonDecode(snapshot.data.toString());
        final podcast = data['data'];
        _init(snapshot);
        return Column(
          children: <Widget>[
            _PodcastHeadlineText(podcast: podcast),
            _PodcastImage(podcast: podcast),
            _PodcastDate(podcast: podcast),
            _PodcastBodyText(podcast: podcast),
            _ControlButtons(_player),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: _player.seek,
                );
              },
            ),
          ],
        );
      },
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
                builder(widget.id),
                pineappleSingle()
              ],
            ),
          ),
        )
    );
  }
}

class _ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const _ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Opens volume slider dialog
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () {
                showSliderDialog(
                  context: context,
                  title: "Adjust volume",
                  divisions: 10,
                  min: 0.0,
                  max: 1.0,
                  value: player.volume,
                  stream: player.volumeStream,
                  onChanged: player.setVolume,
                );
              },
            ),

            /// This StreamBuilder rebuilds whenever the player state changes, which
            /// includes the playing/paused state and also the
            /// loading/buffering/ready state. Depending on the state we show the
            /// appropriate button or loading indicator.
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    width: 64.0,
                    height: 64.0,
                    child: const CircularProgressIndicator(),
                  );
                } else if (playing != true) {
                  return CircleAvatar(
                    radius: 64.0,
                    backgroundColor: const Color(0xff94c29a),
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                      ),
                      iconSize: 64.0,
                      onPressed: player.play,
                    ),
                  );
                } else if (processingState != ProcessingState.completed) {
                  return CircleAvatar(
                    radius: 64.0,
                    backgroundColor: const Color(0xff94c29a),
                    child: IconButton(
                      icon: const Icon(
                        Icons.pause,
                        color: Colors.white,
                      ),
                      iconSize: 64.0,
                      onPressed: player.pause,
                    ),
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.replay),
                    iconSize: 64.0,
                    onPressed: () => player.seek(Duration.zero),
                  );
                }
              },
            ),
            // Opens speed slider dialog
            StreamBuilder<double>(
              stream: player.speedStream,
              builder: (context, snapshot) => IconButton(
                icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  showSliderDialog(
                    context: context,
                    title: "Adjust speed",
                    divisions: 10,
                    min: 0.5,
                    max: 1.5,
                    value: player.speed,
                    stream: player.speedStream,
                    onChanged: player.setSpeed,
                  );
                },
              ),
            ),
          ],
        ));
  }
}

class _PodcastHeadlineText extends StatelessWidget {
  const _PodcastHeadlineText({Key? key, required this.podcast}) : super(key: key);
  final dynamic podcast;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(podcast[0]['title'],
                    textAlign: TextAlign.left,
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PodcastBodyText extends StatelessWidget {
  const _PodcastBodyText({Key? key, required this.podcast}) : super(key: key);
  final dynamic podcast;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: MarkdownBody(
              data: removeAllHtmlTags(podcast[0]['description']),
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                    color: Colors.black, fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodcastDate extends StatelessWidget {
  const _PodcastDate({Key? key, required this.podcast}) : super(key: key);
  final dynamic podcast;
  @override
  Widget build(BuildContext context) {
    final publicationDate =
    DateTime.tryParse(podcast[0]['publication_date']);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                  DateFormat.yMMMMd('en_US').format(publicationDate!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16.0, color: Colors.purple)),
            ),
          )
        ],
      ),
    );
  }
}

class _PodcastImage extends StatelessWidget {
  const _PodcastImage({Key? key, required this.podcast}) : super(key: key);
  final dynamic podcast;
  @override
  Widget build(BuildContext context) {
    try {
      if (podcast[0]["hero_image"] == "") {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 350,
          child: Image.asset('assets/Portico.jpg',
              fit: BoxFit.fill,
              color: const Color.fromRGBO(117, 117, 117, 0.9),
              colorBlendMode: BlendMode.modulate),
        );
      } else {
        return  SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: CircleAvatar(
              radius: 100.0,
              backgroundImage: NetworkImage(
                podcast[0]['hero_image']['data']['url'],
              ),
            ));
      }
    } on TypeError {
      return const SizedBox.shrink();
    }
  }
}