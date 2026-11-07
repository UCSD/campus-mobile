/// ============================================================================
/// File: esrimap_auth_handler.dart
/// Description: Custom ArcGIS Authentication Challenge Handler that fetches and
///              caches access tokens for secure ArcGIS Online / Enterprise services.
/// ============================================================================

import 'dart:convert';

import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Challenge handler implementation for authenticating protected ArcGIS REST services.
class AgeAuthChallengeHandler implements ArcGISAuthenticationChallengeHandler {
  /// Endpoint URL used to retrieve authorization tokens.
  final String tokensUrl;

  /// Cached token for ArcGIS Enterprise server hosts.
  String? _cachedAgeToken;
  DateTime? _ageTokenExpiry;

  /// Cached token for ArcGIS Online (arcgis.com) hosts.
  String? _cachedAgoToken;
  DateTime? _agoTokenExpiry;

  /// Creates an instance of [AgeAuthChallengeHandler] with the specified [tokensUrl].
  AgeAuthChallengeHandler(this.tokensUrl);

  /// Internal helper to retrieve an active token for the requested [host], reusing cached tokens if valid.
  Future<(String?, DateTime?)> _getTokenForHost(String host) async {
    final isAgo = host.contains('arcgis.com');

    // Return cached token if valid and not expiring within 5 minutes
    if (isAgo) {
      final isAgoCachedValid =
          _cachedAgoToken != null &&
          _agoTokenExpiry != null &&
          DateTime.now().isBefore(_agoTokenExpiry!.subtract(const Duration(minutes: 5)));
      if (isAgoCachedValid) return (_cachedAgoToken, _agoTokenExpiry);
    } else {
      final isAgeCachedValid =
          _cachedAgeToken != null &&
          _ageTokenExpiry != null &&
          DateTime.now().isBefore(_ageTokenExpiry!.subtract(const Duration(minutes: 5)));
      if (isAgeCachedValid) return (_cachedAgeToken, _ageTokenExpiry);
    }

    // Request fresh authentication tokens from server endpoint
    final response = await http.get(Uri.parse(tokensUrl));
    final isTokenFetchNotOk = response.statusCode != 200;
    if (isTokenFetchNotOk) throw Exception('Token fetch failed: ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Cache Enterprise token
    _cachedAgeToken = data['age']?['token'] as String?;
    final ageExpiresIn = data['age']?['expires_in'] as int? ?? 7200;
    _ageTokenExpiry = DateTime.now().add(Duration(seconds: ageExpiresIn));

    // Cache ArcGIS Online token
    _cachedAgoToken = data['ago']?['token'] as String?;
    final agoExpiresIn = data['ago']?['expires_in'] as int? ?? 7200;
    _agoTokenExpiry = DateTime.now().add(Duration(seconds: agoExpiresIn));

    return isAgo ? (_cachedAgoToken, _agoTokenExpiry) : (_cachedAgeToken, _ageTokenExpiry);
  }

  /// Handles incoming ArcGIS authentication challenges by attaching pregenerated token credentials.
  @override
  Future<void> handleArcGISAuthenticationChallenge(ArcGISAuthenticationChallenge challenge) async {
    final host = challenge.requestUri.host;
    int maxRetries = 5;
    int retryDelaySeconds = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final (token, expiry) = await _getTokenForHost(host);
        if (token == null || expiry == null) {
          challenge.continueAndFail();
          return;
        }

        final tokenInfo = TokenInfo.create(accessToken: token, expirationDate: expiry, isSslRequired: true);
        if (tokenInfo == null) {
          challenge.continueAndFail();
          return;
        }

        final credential = PregeneratedTokenCredential(uri: challenge.requestUri, tokenInfo: tokenInfo, referer: '');
        challenge.continueWithCredential(credential);
        return; // Success, exit the loop
      } catch (e) {
        debugPrint('Auth challenge failed on attempt $attempt: $e');
        if (attempt == maxRetries) {
          challenge.continueAndFail();
          return;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: retryDelaySeconds));
        retryDelaySeconds *= 2;
      }
    }
  }
}
