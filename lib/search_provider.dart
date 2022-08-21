import 'package:flutter/material.dart';
import 'package:pingolearn_ass_rexord_search/api/get_search_response.dart';
import 'package:pingolearn_ass_rexord_search/data/search_response.dart';

class SearchProvider extends ChangeNotifier {
  bool isLoading = false;
  // late List<Definition> _definitionslist = [];
  SearchResponse? _searchResponse;

  String? sWord;
  SearchResponse? get searchResponse => _searchResponse;

  // SearchProvider() {}

  Future<void> getDefinitionslistApiCall() async {
    isLoading = true;
    // notifyListeners();

    await SearchResponseApi.getDictionaryData(sWord).then((value) {
      // _searchResponse = value;
      // print("HomeUI: ${_searchResponse?.word}");
      // print("HomeUI: ${_searchResponse?.definitions?[0].definition}");
      // print("HomeUI: ${_searchResponse?.definitions?[0].example}");
      // _definitionslist = value.definitions;
      // print("_definitionslist: $_definitionslist");
      isLoading = false;
      print("VALUE: ${value.word}");
      _searchResponse = value;
      notifyListeners();
    }, onError: (e) {
      isLoading = false;
      print("ERROR IN GET _definitionslist  " + e.toString());
    });
    // notifyListeners();
  }
}
