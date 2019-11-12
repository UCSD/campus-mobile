// provider_setup.dart
import 'package:campus_mobile_beta/core/services/availability_service.dart';
import 'package:provider/provider.dart';

List<SingleChildCloneableWidget> providers = [
  ...independentServices,
];
List<SingleChildCloneableWidget> independentServices = [
  Provider.value(value: AvailabilityService())
];
