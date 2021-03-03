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
  static final double pcLongitude = -117.237006;
  static final double pcLatitude = 32.880006;
  double userDistanceFromPriceCenter;
  List<String> allowableDevices;
  Map<String, dynamic> deviceTypes;

  WayfindingConstantsModel(
      {this.allowableDevices,
      this.deviceTypes,
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
          qualifiedDevicesThreshold: constantsJson["uniqueDevices"],
          distanceThreshold: constantsJson["distanceThreshold"],
          dwellTimeThreshold: constantsJson["dwellTimeThreshold"],
          scanDuration: constantsJson["scanDuration"],
          scanWaitTime: constantsJson["waitTime"],
          scanIntervalAllowance: constantsJson["scanIntervalAllowance"],
          backgroundScanInterval: constantsJson["backgroundScanInterval"],
          deletionInterval: constantsJson["deletionInterval"],
          milesFromPC: constantsJson['milesFromPC'].toDouble());
}


