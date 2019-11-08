import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:campus_mobile_experimental/core/models/data.dart';

/// The service responsible for networking requests
class Api {
    static const endpoint = 'https://jsonplaceholder.typicode.com/users/1';

    var client = new http.Client();

    Future<Data> getTest() async {
        // Get user profile for id
        var response = await client.get('$endpoint');

        // Convert and return
        return json.decode(response.body);
    }
}
