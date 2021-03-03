class WayfindingConstantsModel {
  int qualifyingDevices;
  int qualifiedDevicesThreshold;
  int distanceThreshold;
  int dwellTimeThreshold;
  int scanIntervalAllowance;
  int backgroundScanInterval;
  int deletionInterval;
  int scanDuration;
  int waitTime;
  int dwellTime;
  double milesFromPC;
  final double pcLongitude = -117.237006;
  final double pcLatitude = 32.880006;
  double userDistanceFromPriceCenter;
  List<String> allowableDevices;
  List<String> deviceTypes;

  WayfindingConstantsModel(
      List<String> allowableDevices,
      List<String> deviceTypes,
      int qualifiedDevicesThreshold,
      int distanceThreshold,
      int dwellTimeThreshold,
      int scanDuration,
      int waitTime,
      int scanIntervalAllowance,
      int backgroundScanInterval,
      int deletionInterval,
      int milesFromPC
      ){
    this.allowableDevices = allowableDevices;
    this.deviceTypes = deviceTypes;
    this.qualifiedDevicesThreshold = qualifiedDevicesThreshold;
    this.distanceThreshold = distanceThreshold;
    this.dwellTimeThreshold = dwellTimeThreshold;
    this.scanDuration = scanDuration;
    this.

  }


}