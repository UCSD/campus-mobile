import 'package:campus_mobile/core/services/networking.dart';

class NewsModel {
  Future<dynamic> getNews() async {
    print('getting news');
    NetworkHelper networkHelper = NetworkHelper(
        'https://2jjml3hf27.execute-api.us-west-2.amazonaws.com/prod/events/student');

    var data = await networkHelper.getData();
    return data;
  }
}
