import 'package:campus_mobile_experimental/core/models/news.dart';
import 'package:campus_mobile_experimental/core/services/news.dart';
import 'package:get/get.dart';

/// GetX is a state manager that allows variables to be observable (widgets using the variable will be notified if the value changes) by using the `.obs` keyword
/// To access or set the value in an observable variable, you do so by using the `.value` keyword
class NewsGetX extends GetxController {
  ///INITIALIZE SERVICES
  NewsService newsService = NewsService();
  Rx<NewsModel?> _newsModels = NewsModel().obs;

  ///INITIALIZE STATES
  Rx<bool> _isLoading = false.obs;
  Rxn<String> _error = Rxn<String>();
  Rxn<DateTime> _lastUpdated = Rxn<DateTime>();

  /// When Get.put(NewsGetX()) is called from any widget, initialize by calling fetchNews() to fetch data
  @override
  Future<void> onInit() async {
    super.onInit();
    fetchNews();
  }

  /// Fetch from endpoint and fill newsModels for other widgets to access
  void fetchNews() async {
    // Set states so that other widgets no whether data is currently being fetched or not
    _isLoading.value = true;
    _error.value = null;

    // Fetch the data or set the error value if data couldn't be fetched
    if (await newsService.fetchData()) {
      _newsModels.value = newsService.newsModels;
      // lastUpdated.value = DateTime.now();
    } else {
      ///TODO: determine what error to show to the user
      _error.value = newsService.error;
    }

    // Let other widgets know that data has arrived
    _isLoading.value = false;
  }

  ///SIMPLE GETTERS
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  DateTime? get lastUpdated => _lastUpdated.value;
  NewsModel? get newsModels => _newsModels.value;
}
