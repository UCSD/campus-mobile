// Uses Service that Feeds the Model global variable.
// This model global variable can then be used to feed anything (data will be housed at model).
import 'package:flutter/cupertino.dart';
import 'mock_api_call_model.dart';
import 'mock_api_call_service.dart';

/// Step 8) Create Provider Class (always extend ChangeNotifier)
class MockAPIProvider extends ChangeNotifier {
  // Instance status variables (same as Service)
  bool? _isLoading;
  DateTime? _lastUpdated;
  String? _error;
  MockAPIModel? _mockAPIModel;        // Model
  MockAPIService? _mockAPIService;    // Service

  // Constructor to initialize service and model.
  MockAPIProvider() {
    this._isLoading = false;
    this._mockAPIModel = MockAPIModel();
    this._mockAPIService = MockAPIService();
  }

  /// Step 9) Create the function that provides the caller file with desired data
  /// TODO: Fix this so that you can see the displayed data. USE POSTMAN NEXT TO MOCK THIS PROCESS (API CALL)
  void fetchLocation(String locationTitle) async {
    // Update status variables (and global variables with notifyListeners()
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Input error handling
    if (locationTitle.trim().isEmpty) {
      _error = "Location title cannot be empty.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Fetch the desired data and store it in model (in this case, location's data given its name)
    try {
      final result = await _mockAPIService!.fetchLocation(locationTitle);
      if (result) {
        _mockAPIModel = _mockAPIService?.getMockAPIModel;
        _lastUpdated = DateTime.now();
      }
      else {
        _error = _mockAPIService?.error;
      }
    }
    catch (e) {
      _error = "An error occurred: $e";
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }

    print('Fetch location completed');
  }

  /// Step 10) Create getters so that the file that needs the data can access it (exact same as service).
  String? get error => _error;
  MockAPIModel? get getMockAPIModel => _mockAPIModel;
  bool? get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
}
