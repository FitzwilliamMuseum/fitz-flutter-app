import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResult {
  SearchResult(
      {required this.title,
        required this.url,
        required this.image,
        required this.id});

  final String title;
  final String url;
  final String image;
  final String id;

  factory SearchResult.fromJson(Map<String, dynamic> data) {
    return SearchResult(
        title: data['title'],
        url: data['slug'],
        image: data['hero_image']['data']['thumbnails'][2]['url'],
        id: data['stop_number'].toString()
    );
  }
}

class SearchResultsParser {
  SearchResultsParser();

  Future<List<SearchResult>> parseInBackground(String encodedJson) async {
    return compute(parse, encodedJson);
  }

  List<SearchResult> parse(String encodedJson) {
    final jsonData = jsonDecode(encodedJson);
    final resultsJson = jsonData['data'] as List<dynamic>;
    return resultsJson.map((json) => SearchResult.fromJson(json)).toList();
  }
}

class APIClient {
  Future<List<SearchResult>> downloadAndParseJson() async {
    final response = await http.get(Uri.parse(
        'https://content.fitz.ms/fitz-website/items/audio_guide?fields=*.*.*.*&meta=&sort=id&limit=100'));
    if (response.statusCode == 200) {
      final parser = SearchResultsParser();
      return parser.parseInBackground(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load json');
    }
  }
}

final apiClientProvider = Provider<APIClient>((ref) {
  return APIClient();
});

final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) {
  return ref.watch(apiClientProvider).downloadAndParseJson();
});