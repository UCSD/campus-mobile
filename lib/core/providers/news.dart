import 'package:get/get.dart';

import '../models/news.dart';
import '../services/news.dart';

class NewsController extends GetxController {
  ///STATES
  var isLoading = false.obs;
  var lastUpdated = DateTime.now().obs;
  var error = ''.obs;

  ///MODELS
  var newsModels = NewsModel().obs;

  ///SERVICES
  final NewsService _newsService = Get.put(NewsService()); // Inject service

  @override
  void onInit() {
    super.onInit();
    fetchNews(); // Call fetchNews when the controller is initialized
  }

  ///FETCH DATA
  Future<void> fetchNews() async {
    isLoading.value = true;

    if (await _newsService.fetchData()) {
      newsModels.value = _newsService.newsModels;
      lastUpdated.value = DateTime.now();
      print("loading newsCard");
    }
    else {
      error.value = _newsService.error!;
      print("not loading newsCard");
    }
    print(newsModels.value);
    isLoading.value = false;
  }
}