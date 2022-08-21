import 'dart:convert';

import 'package:pingolearn_ass_rexord_search/data/search_response.dart';
import 'package:http/http.dart' as http;

class SearchResponseApi {
  static String baseUrl = 'https://owlbot.info';
  static Future<SearchResponse> getDictionaryData(
    String? word,
  ) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token 055862458bcc01d9604e9559aab727d91d5d2fe4'
      };
      final _url = '$baseUrl/api/v4/dictionary/$word';
      final Uri uri = Uri.parse(_url);
      var response = await http.get(uri, headers: headers);
      print("response---> ${response}");

      print("response--->body" + response.body);

      final responseModel = SearchResponse.fromJson(jsonDecode(response.body));
      print("response--->body1" + responseModel.word.toString());
      return responseModel;
    } catch (e) {
      throw Exception(e);
    }
  }
}
