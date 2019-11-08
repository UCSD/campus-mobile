import 'package:provider/provider.dart';

import 'package:campus_mobile_experimental/core/services/api_test.dart';

List<SingleChildCloneableWidget> providers = [
    ...independentServices,
];

List<SingleChildCloneableWidget> independentServices = [
    Provider.value(value: Api())
];
