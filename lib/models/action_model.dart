import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CovidNewsResult {
  CovidNewsResult({
    required this.title,
    required this.text
  });

  final String title;
  final String text;

  factory CovidNewsResult.fromJson(Map<String, dynamic> data) {
    return CovidNewsResult(
        title: data['title'],
        text: data['text']
    );
  }
}

class CovidNewsResultParser {
  CovidNewsResultParser();

  Future<List<CovidNewsResult>> parseInBackground(String encodedJson) async {
    return compute(parse, encodedJson);
  }

  List<CovidNewsResult> parse(String encodedJson) {
    final jsonData = jsonDecode(encodedJson);
    final resultsJson = jsonData['data'] as List<dynamic>;
    return resultsJson.map((json) => CovidNewsResult.fromJson(json)).toList();
  }
}

class APIClient {
  Future<List<CovidNewsResult>> downloadAndParseJson() async {
    final response = await http.get(Uri.parse(
        'https://content.fitz.ms/fitz-website/items/visit_us_components?fields=*.*.*.*&sort=-id&limit=1&filter[id][eq]=2'));
    if (response.statusCode == 200) {
      final parser = CovidNewsResultParser();
      return parser.parseInBackground(response.body);
    } else {
      throw Exception('Failed to load json');
    }
  }
}

final apiClientProvider = Provider<APIClient>((ref) {
  return APIClient();
});

final searchResultsProvider = FutureProvider<List<CovidNewsResult>>((ref) {
  return ref.watch(apiClientProvider).downloadAndParseJson();
});