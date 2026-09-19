import 'package:flutter_dotenv/flutter_dotenv.dart';

// MA-707 TGPT request auth START
bool tgptUsesWso2Proxy(String endpoint) => endpoint.contains('/tgpt-mobileproxy/');

String tgptAuthMode({required String endpoint, required bool isLoggedIn}) {
  if (tgptUsesWso2Proxy(endpoint)) return 'wso2-basic';
  return isLoggedIn ? 'user-bearer' : 'public-basic';
}

Map<String, String> tgptRequestHeaders({
  required String endpoint,
  required bool isLoggedIn,
  required String accessToken,
}) {
  final bool useWso2Basic = tgptUsesWso2Proxy(endpoint);
  final String authorization = useWso2Basic || !isLoggedIn
      ? dotenv.get('MOBILE_APP_PUBLIC_DATA_KEY')
      : 'Bearer $accessToken';

  return <String, String>{
    'accept': 'application/json',
    'content-type': 'application/json',
    'Authorization': authorization,
  };
}

// MA-707 TGPT request auth END
