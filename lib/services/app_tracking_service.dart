import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

class AppTrackingService {
  static Future<void> requestTrackingIfNeeded() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }
    } catch (e) {
      debugPrint('Errore ATT: $e');
    }
  }
}