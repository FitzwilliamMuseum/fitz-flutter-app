import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResult {
  SearchResult(
      {required this.title,
        required this.date,
        required this.url,
        required this.excerpt,
        required this.image,
        required this.id});

  final String title;
  final String date;
  final String url;
  final String excerpt;
  final String image;
  final String id;

  factory SearchResult.fromJson(Map<String, dynamic> data) {
    return SearchResult(
        title: data['article_title'],
        date: data['publication_date'],
        url: 'https://fitz.ms',
        image: data['field_image']['data']['thumbnails'][2]['url'],
        excerpt: data["article_excerpt"],
        id: data['id'].toString());
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
        'https://content.fitz.ms/fitz-website/items/news_articles?fields=article_title,id,publication_date,*.*&sort=-id&limit=6'));
    if (response.statusCode == 200) {
      final parser = SearchResultsParser();
      return parser.parseInBackground(response.body);
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
