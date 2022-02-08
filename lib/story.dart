import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utilities/icons.dart';
import 'utilities/string_replace.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  fetchData(http.Client client, String id) async {
    final uri =
        "https://content.fitz.ms/fitz-website/items/news_articles?fields=article_title,id,publication_date,*.*&limit=1&filter[id][eq]=" +
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
        final news = data['data'];
        return Column(
          children: <Widget>[
            _NewsImage(news: news),
            _NewsHeadline(news: news),
            _NewsArticleDate(news: news),
            _NewsArticleBody(news: news)
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
      ),
    );
  }
}

class _NewsHeadline extends StatelessWidget {
  const _NewsHeadline({Key? key, required this.news}) : super(key: key);
  final dynamic news;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                news[0]["article_title"],
                textAlign: TextAlign.left,
                style: GoogleFonts.libreBaskerville(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage({Key? key, required this.news}) : super(key: key);
  final dynamic news;

  @override
  Widget build(BuildContext context) {
    try {
      if (news[0]["hero_image"] == "") {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 350,
            child: Image.asset('assets/Portico.jpg',
                fit: BoxFit.fill,
                color: const Color.fromRGBO(117, 117, 117, 0.9),
                colorBlendMode: BlendMode.modulate),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 250,
              child: CircleAvatar(
                radius: 100.0,
                backgroundImage: NetworkImage(
                  news[0]['field_image']['data']['url'],
                ),
              )),
        );
      }
    } on TypeError {
      return const SizedBox.shrink();
    }
  }
}

class _NewsArticleBody extends StatelessWidget {
  const _NewsArticleBody({Key? key, required this.news}) : super(key: key);
  final dynamic news;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: MarkdownBody(
              data: removeAllHtmlTags(news[0]['article_body']),
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                    color: Colors.black, fontSize: 16, height: 1.5),
                blockquote: const TextStyle(
                    color: Colors.red, fontSize: 16, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsArticleDate extends StatelessWidget {
  const _NewsArticleDate({Key? key, required this.news}) : super(key: key);
  final dynamic news;

  @override
  Widget build(BuildContext context) {
    final pubDate = DateTime.tryParse(news[0]['publication_date']);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: Align(
              alignment: Alignment.center,
              child: Text(DateFormat.yMMMMd('en_US').format(pubDate!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0, color: Colors.purple)),
            ),
          )
        ],
      ),
    );
  }
}
