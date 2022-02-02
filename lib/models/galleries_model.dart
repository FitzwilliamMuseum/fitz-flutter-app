import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResult {
  SearchResult(
      {required this.id,
        required this.title,
        required this.url,
        required this.image,
        required this.status});

  final String id;
  final String title;
  final String url;
  final String image;
  final String status;

  factory SearchResult.fromJson(Map<String, dynamic> data) {
    return SearchResult(
        id: data['id'].toString(),
        title: data['gallery_name'],
        url: data['slug'],
        image: data['hero_image']['data']['thumbnails'][2]['url'],
        status: data["gallery_status"][0]);
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
        "https://content.fitz.ms/fitz-website/items/galleries?fields=gallery_name,id,slug,gallery_status,hero_image.*&sort=id"));

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