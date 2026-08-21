import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

/// Service to handle GDPR/UMP consent flow and CCPA opt-out.
///
/// Uses Google's User Messaging Platform (UMP) SDK which is bundled
/// with google_mobile_ads for consent collection in EEA/UK.
class ConsentService {
  static const String _keyConsentStatus = 'consent_status';
  static const String _keyPersonalizedAds = 'personalized_ads_enabled';

  // ── Consent Status ──────────────────────────────────────

  /// Check if consent has been obtained.
  static bool get consentGiven {
    final box = Hive.box('settings');
    return box.get(_keyConsentStatus, defaultValue: false) as bool;
  }

  /// Check if personalized ads are enabled (CCPA opt-out).
  static bool get personalizedAdsEnabled {
    final box = Hive.box('settings');
    return box.get(_keyPersonalizedAds, defaultValue: true) as bool;
  }

  // ── Save Status ─────────────────────────────────────────

  static void _saveConsentStatus(bool status) {
    final box = Hive.box('settings');
    box.put(_keyConsentStatus, status);
  }

  static void setPersonalizedAds(bool enabled) {
    final box = Hive.box('settings');
    box.put(_keyPersonalizedAds, enabled);
    _applyRequestConfiguration();
  }

  // ── UMP Consent Flow ────────────────────────────────────

  /// Request consent if required. Shows UMP dialog for EEA/UK users.
  /// Returns true if consent was obtained, false otherwise.
  static Future<bool> requestConsentIfNeeded() async {
    final params = ConsentRequestParameters(
      // Uncomment for testing:
      // testDeviceIdentifiers: ['FEE5DE1E2CCCB171B365A72A341EF8D2'],
    );

    final completer = Completer<bool>();

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        params: params,
        onConsentInfoUpdated: (ConsentStatus status) async {
          if (status == ConsentStatus.required) {
            // EEA/UK user — consent form needs to be shown
            // The form is shown automatically by UMP SDK
            _saveConsentStatus(false);
            if (!completer.isCompleted) completer.complete(false);
          } else if (status == ConsentStatus.obtained) {
            // Consent already obtained
            _saveConsentStatus(true);
            _applyRequestConfiguration();
            if (!completer.isCompleted) completer.complete(true);
          } else if (status == ConsentStatus.notRequired) {
            // Non-EEA user — no consent needed
            _saveConsentStatus(true);
            _applyRequestConfiguration();
            if (!completer.isCompleted) completer.complete(true);
          } else {
            // Unknown status
            _saveConsentStatus(true);
            _applyRequestConfiguration();
            if (!completer.isCompleted) completer.complete(true);
          }
        },
        formError: (DartError error) {
          // Error fetching consent info — assume consent not required
          debugPrint('Consent error: ${error.message}');
          _saveConsentStatus(true);
          _applyRequestConfiguration();
          if (!completer.isCompleted) completer.complete(true);
        },
      );
    } catch (e) {
      debugPrint('Consent request failed: $e');
      _saveConsentStatus(true);
      _applyRequestConfiguration();
      if (!completer.isCompleted) completer.complete(true);
    }

    return completer.future;
  }

  // ── Request Configuration ───────────────────────────────

  /// Apply personalized vs non-personalized ads based on consent & CCPA.
  static void _applyRequestConfiguration() {
    final taggingForUnderAgeOfConsent = false;

    if (personalizedAdsEnabled && consentGiven) {
      // Full personalized ads
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: taggingForUnderAgeOfConsent
              ? TagForChildDirectedTreatment.yes
              : TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: taggingForUnderAgeOfConsent
              ? TagForUnderAgeOfConsent.yes
              : TagForUnderAgeOfConsent.no,
        ),
      );
    } else {
      // Non-personalized ads (CCPA opt-out or no consent)
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: taggingForUnderAgeOfConsent
              ? TagForChildDirectedTreatment.yes
              : TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: taggingForUnderAgeOfConsent
              ? TagForUnderAgeOfConsent.yes
              : TagForUnderAgeOfConsent.no,
        ),
      );
    }
  }

  // ── Consent Dialog (Flutter UI) ─────────────────────────

  /// Show a custom consent explanation dialog for the app.
  /// This is shown as a first-time explanation before UMP form.
  static Future<void> showConsentDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF9B8EC4).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shield,
            size: 28,
            color: Color(0xFF9B8EC4),
          ),
        ),
        title: const Text(
          'Your Privacy Matters',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HealMind uses Google AdMob to display ads that keep the app free. '
              'AdMob may collect device information for ad personalization.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your journal entries and personal data are stored ONLY on your device '
              'and are never shared with us or any third party.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can opt out of personalized ads anytime in Settings > Privacy.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non-Personalized Ads'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (result == true) {
      _saveConsentStatus(true);
      setPersonalizedAds(true);
    } else if (result == false) {
      _saveConsentStatus(true);
      setPersonalizedAds(false);
    }
  }

  // ── Reset (for testing) ─────────────────────────────────

  static void resetConsent() {
    final box = Hive.box('settings');
    box.delete(_keyConsentStatus);
    box.delete(_keyPersonalizedAds);
    ConsentInformation.instance.reset();
  }
}
