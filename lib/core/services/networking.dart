import 'package:http/http.dart' as http;

class NetworkHelper {
  const NetworkHelper();

  Future<dynamic> fetchData(String url) async {
    final _response = await http.get(url);
    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.body;
    } else {
      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch data: ' + _response.body);
    }
  }

  Future<dynamic> authorizedFetch(
      String url, Map<String, String> headers) async {
    final _response = await http.get(url, headers: headers);
    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.body;
    } else {
      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch data: ' + _response.body);
    }
  }

  Future<dynamic> authorizedPost(
      String url, Map<String, String> headers) async {
    final _response = await http.post(url, headers: headers);
    if (_response.statusCode == 200) {
      // If server returns an OK response, return the body
      return _response.body;
    } else {
      ///TODO: log this as a bug because the response was bad
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch data: ' + _response.body);
    }
  }
}
