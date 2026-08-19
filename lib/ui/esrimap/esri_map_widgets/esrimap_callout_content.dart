import 'package:campus_mobile_experimental/core/models/availability.dart';
import 'package:campus_mobile_experimental/core/models/dining.dart';
import 'package:campus_mobile_experimental/core/models/esri_map_models/map_search_result.dart';
import 'package:campus_mobile_experimental/core/models/parking.dart';
import 'package:flutter/material.dart';

class EsriMapCalloutContent extends StatelessWidget {
  final MapSearchResult result;
  final String detail;
  final bool isDark;

  final List<DiningModel> diningModels;
  final List<ParkingModel> parkingModels;
  final List<AvailabilityModel?> availabilityModels;

  const EsriMapCalloutContent({
    Key? key,
    required this.result,
    required this.detail,
    required this.isDark,
    required this.diningModels,
    required this.parkingModels,
    required this.availabilityModels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final String queryName = result.name.toLowerCase().trim();

    // 1. Try to match Dining
    final diningMatch = _findDiningMatch(queryName, diningModels);
    if (diningMatch != null) {
      return _buildCalloutContainer(
        context,
        child: _buildDiningContent(context, diningMatch),
      );
    }

    // 2. Try to match Parking
    final parkingMatch = _findParkingMatch(queryName, parkingModels);
    if (parkingMatch != null) {
      return _buildCalloutContainer(
        context,
        child: _buildParkingContent(context, parkingMatch),
      );
    }

    // 3. Try to match Availability
    final availabilityMatch = _findAvailabilityMatch(queryName, availabilityModels);
    if (availabilityMatch != null) {
      return _buildCalloutContainer(
        context,
        child: _buildAvailabilityContent(context, availabilityMatch),
      );
    }

    // 4. Fallback to generic subtitle if no contextual data is found
    return _buildCalloutContainer(
      context,
      child: _buildFallbackContent(context),
    );
  }

  // --- Matching Logic ---

  DiningModel? _findDiningMatch(String query, List<DiningModel> models) {
    if (query.isEmpty) return null;
    for (var model in models) {
      final name = model.name.toLowerCase().trim();
      if (name == query || query.contains(name) || name.contains(query)) {
        return model;
      }
    }
    return null;
  }

  ParkingModel? _findParkingMatch(String query, List<ParkingModel> models) {
    if (query.isEmpty) return null;
    for (var model in models) {
      final locName = model.locationName.toLowerCase().trim();
      // Use bidirectional containment to catch cases where the map says "Gilman Parking Structure" but the model says "Gilman"
      if (locName == query || query.contains(locName) || locName.contains(query)) {
        return model;
      }
    }
    return null;
  }

  SubLocations? _findAvailabilityMatch(String query, List<AvailabilityModel?> models) {
    if (query.isEmpty) return null;
    for (var model in models) {
      if (model != null) {
        for (var sub in model.subLocations) {
          final subName = sub.name.toLowerCase().trim();
          if (subName == query || query.contains(subName) || subName.contains(query)) {
            return sub;
          }
        }
      }
    }
    return null;
  }

  // --- UI Builders ---

  Widget _buildCalloutContainer(BuildContext context, {required Widget child}) {
    // Exclude semantics here so we can provide a combined label if needed, 
    // or just let the children handle it.
    return Semantics(
      label: detail.isEmpty ? result.name : '${result.name}. $detail',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _buildFallbackContent(BuildContext context) {
    if (detail.isEmpty) return const SizedBox.shrink();
    return Text(
      detail,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontSize: 12,
        height: 1.15,
      ),
    );
  }

  // --- Dining Content ---

  Widget _buildDiningContent(BuildContext context, DiningModel dining) {
    try {
      final isOpen = _isDiningOpen(dining.regularHours);
      final statusColor = isOpen ? Colors.green : Colors.red;
      final statusText = isOpen ? "Open" : "Closed";
      
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (dining.distance != null) ...[
            const SizedBox(width: 6),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.black26,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "${dining.distance!.toStringAsFixed(1)} mi",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ],
      );
    } catch (e) {
      return _buildFallbackContent(context);
    }
  }

  bool _isDiningOpen(RegularHours hours) {
    int weekday = DateTime.now().weekday;
    String? dayHours;
    switch (weekday) {
      case 1: dayHours = hours.mon; break;
      case 2: dayHours = hours.tue; break;
      case 3: dayHours = hours.wed; break;
      case 4: dayHours = hours.thu; break;
      case 5: dayHours = hours.fri; break;
      case 6: dayHours = hours.sat; break;
      case 7: dayHours = hours.sun; break;
    }
    
    if (dayHours == null || dayHours == 'Closed-Closed' || dayHours == 'Invalid Date-Invalid Date') {
      return false;
    }
    
    return true; 
  }

  // --- Parking Content ---

  Widget _buildParkingContent(BuildContext context, ParkingModel parking) {
    try {
      int totalOpen = 0;
      int totalCapacity = 0;

      for (var spotData in parking.availability.values) {
        if (spotData == null || spotData is! Map) continue;
        
        int open = spotData["Open"] is String 
            ? (int.tryParse(spotData["Open"]) ?? 0) 
            : (spotData["Open"] ?? 0);
            
        int total = spotData["Total"] is String 
            ? (int.tryParse(spotData["Total"]) ?? 0) 
            : (spotData["Total"] ?? 0);
            
        totalOpen += open;
        totalCapacity += total;
      }

      if (totalCapacity == 0) {
        return Text(
          "No space data",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
        );
      }

      double percent = totalOpen / totalCapacity;
      if (percent.isNaN) percent = 0.0;

      Color progressColor = Colors.green;
      if (percent < 0.25) progressColor = Colors.red;
      else if (percent < 0.75) progressColor = Colors.orange;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$totalOpen / $totalCapacity Spaces",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: isDark ? Colors.white24 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return _buildFallbackContent(context);
    }
  }

  // --- Availability Content ---

  Widget _buildAvailabilityContent(BuildContext context, SubLocations subLocation) {
    try {
      double percent = subLocation.percentage;
      
      Color progressColor = Color(0xFF109B00); // Green
      if (percent >= 0.75) progressColor = Color(0xFFBD1900); // Red
      else if (percent >= 0.25) progressColor = Color(0xFFFC8900); // Orange

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${(percent * 100).toInt()}% Busy",
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent <= 0.01 ? 0.01 : percent,
                backgroundColor: isDark ? Colors.white24 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return _buildFallbackContent(context);
    }
  }
}
