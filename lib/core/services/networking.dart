import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper(this.url);

  final String url;

  Future<dynamic> getData() async {
    print('get data networking');
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      print('response from server');
      String data = response.body;

      try {
        var json = jsonDecode(data);
        return json;
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
      return '';
    }
  }
}
