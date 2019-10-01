import 'package:provider/provider.dart';

import 'package:campus_mobile/core/services/api_test.dart';

List<SingleChildCloneableWidget> providers = [
    ...independentServices,
];

List<SingleChildCloneableWidget> independentServices = [
    Provider.value(value: Api())
];


class BottomNavigationBarProvider with ChangeNotifier {
    int _currentIndex = 0;

    get currentIndex => _currentIndex;

    set currentIndex(int index) {
        _currentIndex = index;
        notifyListeners();
    }
}
