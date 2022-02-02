import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExhibitionResult {
  ExhibitionResult(
      {required this.title,
        required this.date,
        required this.url,
        required this.image,
        required this.id
      });

  final String title;
  final String date;
  final String url;
  final String image;
  final String id;

  factory ExhibitionResult.fromJson(Map<String, dynamic> data) {
    return ExhibitionResult(
        title: data['exhibition_title'],
        date: data['exhibition_start_date'],
        url: data['slug'],
        image: data['hero_image']['data']['thumbnails'][2]['url'],
        id: data['id'].toString());
  }
}

class ExhibitionResultsParser {
  ExhibitionResultsParser();

  Future<List<ExhibitionResult>> parseInBackground(String encodedJson) async {
    return compute(parse, encodedJson);
  }

  List<ExhibitionResult> parse(String encodedJson) {
    final jsonData = jsonDecode(encodedJson);
    final resultsJson = jsonData['data'] as List<dynamic>;
    return resultsJson.map((json) => ExhibitionResult.fromJson(json)).toList();
  }
}

class APIClient {
  Future<List<ExhibitionResult>> downloadAndParseJson() async {
    final response = await http.get(Uri.parse(
        'https://content.fitz.ms/fitz-website/items/exhibitions?fields=exhibition_title,id,slug,exhibition_narrative,exhibition_start_date,exhibition_end_date,hero_image.*,type,exhibition_status&sort=-exhibition_end_date&limit=12&filter[exhibition_status][eq]=current'));
    if (response.statusCode == 200) {
      final parser = ExhibitionResultsParser();
      return parser.parseInBackground(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load json');
    }
  }
}

final apiClientProvider = Provider<APIClient>((ref) {
  return APIClient();
});

final searchResultsProvider = FutureProvider<List<ExhibitionResult>>((ref) {
  return ref.watch(apiClientProvider).downloadAndParseJson();
});