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
      final appleUri = Uri.parse(appleMapsUrl);
      final canLaunchAppleMaps = await canLaunchUrl(appleUri);
      if (canLaunchAppleMaps) {
        await launchUrl(
          appleUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }
    }

    // Try Google Maps app URL scheme (works on both iOS and Android)
    final googleMapsAppUrl = dotenv.get('GOOGLE_MAPS_APP_URL') + '$lat,$lon&directionsmode=walking';
    final googleAppUri = Uri.parse(googleMapsAppUrl);
    final canLaunchGoogleMapsApp = await canLaunchUrl(googleAppUri);
    if (canLaunchGoogleMapsApp) {
      await launchUrl(
        googleAppUri,
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    // Fall back to Google Maps web
    final googleMapsWebUrl = dotenv.get('GOOGLE_MAPS_WEB_URL') + '$lat,$lon';
    final googleWebUri = Uri.parse(googleMapsWebUrl);
    final canLaunchGoogleMapsWeb = await canLaunchUrl(googleWebUri);
    if (canLaunchGoogleMapsWeb) {
      await launchUrl(
        googleWebUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      // If all else fails, show an error
      debugPrint('Failed to open directions: No map apps available');
    }
  }
}
