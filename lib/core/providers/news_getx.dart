import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/core/services/news.dart';
import 'package:get/get.dart';

/// GetX is a state manager that allows variables to be observable (widgets using the variable will be notified if the value changes) by using the `.obs` keyword
/// To access or set the value in an observable variable, you do so by using the `.value` keyword
class NewsGetX extends GetxController {
  ///INITIALIZE SERVICES
  NewsService newsService = NewsService();
  Rx<NewsModel?> newsModels = NewsModel().obs;

  ///INITIALIZE STATES
  Rx<bool> isLoading = false.obs;
  Rx<String?> error = null.obs;
  // Rx<DateTime?> lastUpdated = null.obs;

  /// When Get.put(NewsGetX()) is called from any widget, initialize by calling fetchNews() to fetch data
  @override
  Future<void> onInit() async {
    super.onInit();
    fetchNews();
  }

  /// Fetch from endpoint and fill newsModels for other widgets to access
  fetchNews() async {
    // Set states so that other widgets no whether data is currently being fetched or not
    isLoading.value = true;
    error.value = null;

    // Fetch the data or set the error value if data couldn't be fetched
    if (await newsService.fetchData()) {
      newsModels.value = newsService.newsModels;
      // lastUpdated.value = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      error.value = newsService.error;
    }

    // Let other widgets know that data has arrived
    isLoading.value = false;
  }
}
