import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SearchResult {
  SearchResult(
      {required this.title,
        required this.url,
        required this.image,
        required this.accession,
        this.fullTitle,
        this.maker,
        this.description,
        this.department});

  final String title;
  final String url;
  final String image;
  final String accession;
  final String? fullTitle;
  final String? maker;
  final String? description;
  final String? department;

  factory SearchResult.fromJson(Map<String, dynamic> data) {
    final identifier = data["identifier"][0];
    return SearchResult(
        title: data['summary_title'],
        url: data['admin']['uri'],
        image: data['multimedia'][0]['processed']['large']['location'],
        fullTitle: data.containsKey("title")
            ? data['title'][0]['value']
            : 'No full title',
        maker: data['lifecycle']['creation'][0].containsKey("maker")
            ? data['lifecycle']['creation'][0]['maker'][0]['summary_title']
            : 'No maker recorded',
        description: data.containsKey("description")
            ? data['description'][0]['value']
            : 'No description at the moment',
        department: data['department']['value'],
        accession: identifier.containsKey("accession_number")
            ? identifier['accession_number']
            : 'No accession number');
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
    final response = await http
        .get(Uri.parse('https://data.fitzmuseum.cam.ac.uk/random/app'));
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