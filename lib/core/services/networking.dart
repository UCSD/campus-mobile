import 'package:http/http.dart' as http;

class NetworkHelper {
  NetworkHelper(this.url);

  bool _isLoading = false;
  http.Response _response;
  String _error;
  final String url;

  Future<dynamic> fetchData() async {
    _error = null;
    _isLoading = true;
    _response = await http.get(url);
    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      _isLoading = false;
      _error = null;
      return _response.body;
    } else {
      _error = _response.body;
      _isLoading = false;

      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  String get error => _error;
  http.Response get response => _response;
  bool get isLoading => _isLoading;
}
