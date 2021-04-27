class WayfindingConstantsModel {
  int qualifyingDevices;
  int qualifiedDevicesThreshold;
  int distanceThreshold;
  int dwellTimeThreshold;
  int scanIntervalAllowance;
  int backgroundScanInterval;
  int deletionInterval;
  int scanDuration;
  int scanWaitTime;
  int currentDwellTime;
  double milesFromPC;
  final double pcLongitude = -117.237006;
  final double pcLatitude = 32.880006;
  double userDistanceFromPriceCenter;
  List<String> allowableDevices;
  Map<String, dynamic> deviceTypes;

  WayfindingConstantsModel(
      {this.allowableDevices,
      this.deviceTypes,
      this.qualifyingDevices,
      this.qualifiedDevicesThreshold,
      this.distanceThreshold,
      this.dwellTimeThreshold,
      this.scanDuration,
      this.scanWaitTime,
      this.scanIntervalAllowance,
      this.backgroundScanInterval,
      this.deletionInterval,
      this.milesFromPC});

  factory WayfindingConstantsModel.fromJson(
          Map<String, dynamic> deviceTypesJson,
          Map<String, dynamic> constantsJson) =>
      WayfindingConstantsModel(
          allowableDevices: List.from(constantsJson['deviceCharacteristics']),
          deviceTypes: deviceTypesJson,
          qualifyingDevices: 0,
          qualifiedDevicesThreshold: int.parse(constantsJson["uniqueDevices"]),
          distanceThreshold: int.parse(constantsJson["distanceThreshold"]),
          dwellTimeThreshold: int.parse(constantsJson["dwellTimeThreshold"]),
          scanDuration: int.parse(constantsJson["scanDuration"]),
          scanWaitTime: int.parse(constantsJson["waitTime"]),
          scanIntervalAllowance:
              int.parse(constantsJson["scanIntervalAllowance"]),
          backgroundScanInterval: constantsJson["backgroundScanInterval"],
          deletionInterval: constantsJson["deletionInterval"],
          milesFromPC: constantsJson['milesFromPC'].toDouble());
}
