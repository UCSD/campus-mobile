import 'dart:async';
import 'package:campus_mobile_experimental/core/models/news_model.dart';
import 'package:http/http.dart' as http;

class NewsService {
  bool _isLoading = false;
  DateTime _lastUpdated;
  http.Response _response;
  String _error;
  NewsModel _newsModel;

  Future<NewsModel> fetchData() async {
    _error = null;
    _isLoading = true;
    _response = await http.get(
        'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/now_ucsandiego/v1/allstories.json');

    if (_response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      _isLoading = false;
      _error = null;
      try {
        _lastUpdated = DateTime.now();
        return newsModelFromJson(_response.body.toString());
      } catch (e) {
        ///TODO: log this as a bug because the json parsing has failed
        print(e);
        _error = e;
        throw Exception('Failed to load post');
      }
    } else {
      _error = _response.body;
      _isLoading = false;

      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  http.Response get response => _response;
  String get error => _error;
  NewsModel get newsModel => _newsModel;
  bool get isLoading => _isLoading;
  DateTime get lastUpdated => _lastUpdated;
}
