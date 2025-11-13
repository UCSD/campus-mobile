import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for opening directions to a specific location
class DirectionsHelper {
  /// Opens directions using the best available map app based on platform and availability
  static Future<void> openDirections(double lat, double lon) async {
    if (Platform.isIOS) {
      // On iOS, try Apple Maps native app first
      final appleMapsUrl = dotenv.get('APPLE_MAPS_URL') + '$lat,$lon&dirflg=w';
      if (await canLaunchUrl(appleMapsUrl as Uri)) {
        await launchUrl(
          appleMapsUrl as Uri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }
    }

    // Try Google Maps app URL scheme (works on both iOS and Android)
    final googleMapsAppUrl = dotenv.get('GOOGLE_MAPS_APP_URL') + '$lat,$lon&directionsmode=walking';
    if (await canLaunchUrl(googleMapsAppUrl as Uri)) {
      await launchUrl(
        googleMapsAppUrl as Uri,
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    // Fall back to Google Maps web
    final googleMapsWebUrl = dotenv.get('GOOGLE_MAPS_WEB_URL') + '$lat,$lon';
    if (await canLaunchUrl(googleMapsWebUrl as Uri)) {
      await launchUrl(
        googleMapsWebUrl as Uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // If all else fails, show an error
      debugPrint('Failed to open directions: No map apps available');
    }
  }
}
