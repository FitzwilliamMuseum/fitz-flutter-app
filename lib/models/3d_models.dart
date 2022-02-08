import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResult {
  SearchResult({
    required this.id,
    required this.title,
    required this.adlibID,
    required this.image,
    required this.glb
  });

  final String id;
  final String title;
  final String adlibID;
  final String image;
  final String glb;


  factory SearchResult.fromJson(Map<String, dynamic> data) {
    return SearchResult(
        id: data['id'].toString(),
        title: data['title'],
        adlibID: data['adlib_id'],
        image: data['thumbnail']['data']['thumbnails'][2]['url'],
        glb: data["glb_file"]["data"]["full_url"]
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
        'https://content.fitz.ms/fitz-website/items/app_3d_models?fields=*.*.*.*&sort=-id&limit=50'));

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