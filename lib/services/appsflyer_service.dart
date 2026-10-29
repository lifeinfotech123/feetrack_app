import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/app_router.dart';

class AppsFlyerService {
  static AppsflyerSdk? _appsflyerSdk;
  static StreamSubscription? _linkSubscription;
  static bool _deepLinkHandled = false;

  /// Clean up resources
  static void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  // Pending deep link data — stored when deep link arrives
  // before app is fully loaded (splash/auth not complete yet)
  static int? _pendingJobId;
  static String? _pendingReferralCode;

  // Flag to track if app is ready for navigation
  static bool _isAppReady = false;

  // Whether the user is logged in (set by splash screen)
  static bool _isUserLoggedIn = false;

  /// Initialize AppsFlyer SDK with dev key and OneLink template
  static Future<void> initialize() async {
    try {
      // Direct URI Listener (works across platforms without requiring Apple ID)
      _setupDirectUriListener();

      // Skip AppsFlyer SDK initialization on iOS to avoid requiring or storing any Apple ID
      if (Platform.isIOS) {
        log('AppsFlyer SDK skipped on iOS (no Apple ID stored or required)',
            name: 'APPSFLYER');
        return;
      }

      final AppsFlyerOptions options = AppsFlyerOptions(
        afDevKey: 'eS7j6iQs9oYCgCZecsRFBV',
        appId: 'com.tpipay.feetrack_student_parent', // Android package name
        showDebug: true, // Set to false in production
        timeToWaitForATTUserAuthorization: 10, // iOS ATT dialog timeout
      );

      _appsflyerSdk = AppsflyerSdk(options);

    // ============================
    // 1. Unified Deep Linking (UDL)
    // Handles BOTH direct deep links (app installed)
    // AND deferred deep links (app freshly installed)
    // ============================
    _appsflyerSdk!.onDeepLinking((DeepLinkResult result) {
      log('AppsFlyer UDL Result: ${result.status}', name: 'APPSFLYER');

      switch (result.status) {
        case Status.FOUND:
          final deepLink = result.deepLink;
          if (deepLink != null) {
            _deepLinkHandled =
                true; // Prevent app_links fallback from duplicate handling
            final deepLinkValue = deepLink.deepLinkValue;
            // Get referral code from deep_link_sub3 in clickEvent map
            final referralCode =
                deepLink.clickEvent['deep_link_sub3']?.toString() ?? '';
            log('Deep link value: $deepLinkValue, referralCode: $referralCode',
                name: 'APPSFLYER');

            if (deepLinkValue != null) {
              _handleDeepLinkData(deepLinkValue, referralCode);
            }
          }
          break;
        case Status.NOT_FOUND:
          log('Deep link not found', name: 'APPSFLYER');
          break;
        case Status.ERROR:
          log('Deep link error: ${result.error}', name: 'APPSFLYER');
          break;
        case Status.PARSE_ERROR:
          log('Deep link parse error', name: 'APPSFLYER');
          break;
      }
    });

    // ============================
    // 2. Direct Deep Link Callback (App Open Attribution)
    // Fires when app is opened via URI Scheme or direct link
    // ============================
    _appsflyerSdk!.onAppOpenAttribution((dynamic rawData) {
      final data = _asStringKeyedMap(rawData);
      if (data == null) {
        log(
          'Ignoring AppsFlyer attribution data of type ${rawData.runtimeType}',
          name: 'APPSFLYER',
        );
        return;
      }
      log('AppsFlyer App Open Attribution: $data', name: 'APPSFLYER');

      final payload = _asStringKeyedMap(data['payload']) ?? data;
      final deepLinkValue =
          payload['deep_link_value'] ?? payload['af_dp'] ?? payload['link'];
      final referralCode = payload['deep_link_sub3']?.toString() ??
          payload['referral']?.toString() ??
          '';

      if (deepLinkValue != null && deepLinkValue.toString().isNotEmpty) {
        log('App Open Deep link value: $deepLinkValue, referralCode: $referralCode',
            name: 'APPSFLYER');
        _handleDeepLinkData(deepLinkValue.toString(), referralCode);
      }
    });

    // ============================
    // 2. Install Conversion Data (Deferred Deep Link fallback)
    // Fires on FIRST launch after fresh install
    // Contains the attribution data from the OneLink click
    // ============================
    _appsflyerSdk!.onInstallConversionData((dynamic rawData) {
      final data = _asStringKeyedMap(rawData);
      if (data == null) {
        log(
          'Ignoring AppsFlyer install data of type ${rawData.runtimeType}',
          name: 'APPSFLYER',
        );
        return;
      }
      log('Install Conversion Data: $data', name: 'APPSFLYER');

      final status = data['status'];
      if (status == 'success') {
        final payload = _asStringKeyedMap(data['payload']) ?? data;
        final isFirstLaunch = payload['is_first_launch'];

        // Only handle deferred deep link on first launch
        if (isFirstLaunch == true || isFirstLaunch == 'true') {
          final deepLinkValue = payload['deep_link_value'] ??
              payload['af_dp'] ??
              payload['deep_link_sub1'];
          final referralCode = payload['deep_link_sub3']?.toString() ?? '';

          if (deepLinkValue != null && deepLinkValue.toString().isNotEmpty) {
            log('Deferred deep link value: $deepLinkValue, referralCode: $referralCode',
                name: 'APPSFLYER');
            _handleDeepLinkData(deepLinkValue.toString(), referralCode);
          }
        }
      }
    });

    // Start the SDK
    await _appsflyerSdk!.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    log('AppsFlyer SDK initialized successfully', name: 'APPSFLYER');
    } catch (e, stack) {
      log('AppsFlyer SDK initialization failed: $e\n$stack', name: 'APPSFLYER');
    }
  }

  static Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is! Map) return null;
    return value.map<String, dynamic>(
      (key, item) => MapEntry(key.toString(), item),
    );
  }

  /// Listen for incoming URIs directly using app_links package
  static void _setupDirectUriListener() {
    if (_linkSubscription != null) return;
    final appLinks = AppLinks();

    // Handle initial link (app was closed, opened via link)
    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        log('Initial URI received: $uri', name: 'APPSFLYER_URI');
        _handleIncomingUri(uri);
      }
    });

    // Handle links when app is already running (foreground/background)
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      log('Stream URI received: $uri', name: 'APPSFLYER_URI');
      _handleIncomingUri(uri);
    });
  }

  /// Parse incoming URI and extract job ID + referral code
  static void _handleIncomingUri(Uri uri) {
    log('Handling incoming URI: $uri', name: 'APPSFLYER_URI');

    // Skip if AppsFlyer UDL already handled this deep link
    if (_deepLinkHandled) {
      log('Deep link already handled by AppsFlyer UDL, skipping',
          name: 'APPSFLYER_URI');
      _deepLinkHandled = false;
      return;
    }

    String? deepLinkValue;
    String referralCode = '';

    // Check query parameters first (OneLink format)
    // e.g., https://feetrackapp.onelink.me/5tVX?deep_link_value=job_1&deep_link_sub3=Feetrack05
    if (uri.queryParameters.containsKey('deep_link_value')) {
      deepLinkValue = uri.queryParameters['deep_link_value'];
      referralCode = uri.queryParameters['deep_link_sub3'] ?? '';
    }
    // Check custom scheme format: feetrack://job/1?referral=Feetrack05
    else if (uri.scheme == 'feetrack') {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        deepLinkValue = 'job_${pathSegments.last}';
      }
      referralCode = uri.queryParameters['referral'] ??
          uri.queryParameters['deep_link_sub3'] ??
          '';
    }
    // Check path-based format: https://domain.com/job/1
    else if (uri.path.contains('/job/')) {
      final match = RegExp(r'/job/(\d+)').firstMatch(uri.path);
      if (match != null) {
        deepLinkValue = 'job_${match.group(1)}';
      }
      referralCode = uri.queryParameters['referral'] ??
          uri.queryParameters['deep_link_sub3'] ??
          '';
    }

    if (deepLinkValue != null && deepLinkValue.isNotEmpty) {
      log('URI parsed -> deepLinkValue: $deepLinkValue, referralCode: $referralCode',
          name: 'APPSFLYER_URI');
      _handleDeepLinkData(deepLinkValue, referralCode);
    } else {
      log('No deep link value found in URI: $uri', name: 'APPSFLYER_URI');
    }
  }

  /// Parse deep link value and store job ID + referral code
  static void _handleDeepLinkData(String deepLinkValue, String referralCode) {
    // Expected formats:
    // "job_42" -> job ID = 42
    // "42"     -> job ID = 42
    int? jobId;

    if (deepLinkValue.contains('job_')) {
      final match = RegExp(r'job_(\d+)').firstMatch(deepLinkValue);
      if (match != null) {
        jobId = int.tryParse(match.group(1)!);
      }
    } else if (deepLinkValue.contains('/job/')) {
      final match = RegExp(r'/job/(\d+)').firstMatch(deepLinkValue);
      if (match != null) {
        jobId = int.tryParse(match.group(1)!);
      }
    } else {
      jobId = int.tryParse(deepLinkValue);
    }

    if (jobId != null) {
      if (referralCode.isNotEmpty) {
        saveReferralToPrefs(referralCode, jobId: jobId);
      }
      final isLoggedIn = checkIsLoggedIn();
      if (_isAppReady) {
        if (isLoggedIn) {
          log('App ready & user logged in -> Navigating to Job ID: $jobId, referral: $referralCode',
              name: 'APPSFLYER');
          AppRouter.goToJob(jobId,
              referralCode: referralCode.isNotEmpty ? referralCode : null);
        } else {
          log('App ready & user NOT logged in -> Storing pending & navigating to Register with referral: $referralCode',
              name: 'APPSFLYER');
          setPendingJob(jobId, referralCode.isNotEmpty ? referralCode : null);
          AppRouter.goToRegister(
              referralCode: referralCode.isNotEmpty ? referralCode : null);
        }
      } else {
        // App is still loading (splash/auth) — store for later
        setPendingJob(jobId, referralCode.isNotEmpty ? referralCode : null);
        log('Stored pending job ID: $jobId, referralCode: $referralCode (app not ready yet)',
            name: 'APPSFLYER');
      }
    }
  }

  /// Check if user is currently authenticated
  static bool checkIsLoggedIn() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        final token = authController.getUserToken();
        return authController.isLoggedIn() && token.isNotEmpty;
      }
    } catch (e) {
      log('Error checking login in AppsFlyerService: $e', name: 'APPSFLYER');
    }
    return _isUserLoggedIn;
  }

  /// Store pending job ID and referral code for post-auth navigation & persist in SharedPreferences
  static void setPendingJob(int jobId, String? referralCode) {
    _pendingJobId = jobId;
    _pendingReferralCode = referralCode;
    log('Set pending job ID: $jobId, referralCode: $referralCode',
        name: 'APPSFLYER');
    if (referralCode != null && referralCode.isNotEmpty) {
      saveReferralToPrefs(referralCode, jobId: jobId);
    }
  }

  /// Persist referral code and jobId to SharedPreferences
  static Future<void> saveReferralToPrefs(String referralCode,
      {int? jobId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (referralCode.isNotEmpty) {
        await prefs.setString('saved_referral_code', referralCode);
        log('Saved referral code to SharedPreferences: $referralCode',
            name: 'APPSFLYER');
      }
      if (jobId != null && jobId > 0) {
        await prefs.setInt('saved_pending_job_id', jobId);
        log('Saved pending job ID to SharedPreferences: $jobId',
            name: 'APPSFLYER');
      }
    } catch (e) {
      log('Error saving referral to prefs: $e', name: 'APPSFLYER');
    }
  }

  /// Retrieve saved referral code from SharedPreferences
  static Future<String?> getSavedReferralCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('saved_referral_code');
    } catch (_) {
      return null;
    }
  }

  /// Retrieve saved pending job ID from SharedPreferences
  static Future<int?> getSavedPendingJobId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('saved_pending_job_id');
    } catch (_) {
      return null;
    }
  }

  /// Clear saved referral code & pending job ID from SharedPreferences
  static Future<void> clearSavedReferral() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_referral_code');
      await prefs.remove('saved_pending_job_id');
      log('Cleared saved referral & pending job ID from SharedPreferences',
          name: 'APPSFLYER');
    } catch (_) {}
  }

  static int? getPendingJobId() => _pendingJobId;
  static String? getPendingReferralCode() => _pendingReferralCode;
  static void clearPending() {
    _pendingJobId = null;
    _pendingReferralCode = null;
    clearSavedReferral();
  }

  /// Call this from splash screen after auth check completes
  /// [isLoggedIn] — whether the user has a valid token/session
  static void markAppReady({required bool isLoggedIn}) {
    _isAppReady = true;
    _isUserLoggedIn = isLoggedIn;
    log('App marked ready. LoggedIn: $isLoggedIn', name: 'APPSFLYER');
  }

  /// Navigate to JobDetailScreen with given job ID and referral code via GoRouter
  static void goToJob(int jobId, {String? referralCode}) {
    AppRouter.goToJob(jobId, referralCode: referralCode);
  }

  /// Call this when user logs in normally via phone/OTP or registers without referral code
  /// to ensure user lands on the normal Dashboard
  static void onNormalAuth() {
    _isUserLoggedIn = true;
    _pendingJobId = null;
    _pendingReferralCode = null;
    log('Normal auth completed. User logged in, pending deep links cleared.',
        name: 'APPSFLYER');
  }

  /// Call this when user registers WITH a referral code
  static void onRegisterWithReferral(String referralCode) {
    _isUserLoggedIn = true;
    _pendingReferralCode = referralCode;
    log('Registration with referral completed: $referralCode, pendingJobId: $_pendingJobId',
        name: 'APPSFLYER');
  }

  /// Generate a shareable OneLink for a specific job
  /// Returns the generated OneLink URL string
  static Future<String?> generateJobShareLink({
    required int jobId,
    String? jobTitle,
    String? companyName,
    String? referralCode,
  }) async {
    if (_appsflyerSdk == null) {
      log('AppsFlyer SDK not initialized', name: 'APPSFLYER');
      return null;
    }

    try {
      final Completer<String?> completer = Completer<String?>();

      // Build link parameters using constructor
      final AppsFlyerInviteLinkParams params = AppsFlyerInviteLinkParams(
        channel: 'job_share',
        campaign: 'job_referral',
        customerID: '',
        baseDeepLink: 'https://feetrackapp.onelink.me/5tVX',
        customParams: {
          'deep_link_value': 'job_$jobId',
          'deep_link_sub1': jobTitle ?? '',
          'deep_link_sub2': companyName ?? '',
          'deep_link_sub3': referralCode ?? '',
          'af_force_deeplink': 'true',
        },
      );

      // Set OneLink template ID
      _appsflyerSdk!.setAppInviteOneLinkID('5tVX', (result) {
        log('Set OneLink ID result: $result', name: 'APPSFLYER');
      });

      // Generate the link with success and error callbacks
      _appsflyerSdk!.generateInviteLink(
        params,
        (dynamic result) {
          log('Generated OneLink: $result', name: 'APPSFLYER');
          if (result is Map) {
            final payload = result['payload'];
            if (payload is Map && payload['userInviteURL'] != null) {
              completer.complete(payload['userInviteURL'] as String);
            } else if (result['userInviteURL'] != null) {
              completer.complete(result['userInviteURL'] as String);
            } else {
              completer.complete(result.toString());
            }
          } else if (result is String) {
            completer.complete(result);
          } else {
            completer.complete(result?.toString());
          }
        },
        (dynamic error) {
          log('Error generating OneLink: $error', name: 'APPSFLYER');
          completer.complete(null);
        },
      );

      final link = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      if (link != null && link.isNotEmpty) {
        return link;
      }
    } catch (e) {
      log('Error generating OneLink: $e', name: 'APPSFLYER');
    }

    // Fallback to simple URL if OneLink generation fails
    return 'https://feetrackapp.onelink.me/5tVX?deep_link_value=job_$jobId&deep_link_sub1=${Uri.encodeComponent(jobTitle ?? '')}&deep_link_sub3=${referralCode ?? ''}';
  }

  /// Log a custom in-app event for analytics
  static void logJobViewEvent(int jobId, String? jobTitle) {
    _appsflyerSdk?.logEvent('af_content_view', {
      'af_content_id': jobId.toString(),
      'af_content_type': 'job',
      'af_content': jobTitle ?? '',
    });
  }

  /// Log job apply event for analytics
  static void logJobApplyEvent(int jobId, String? jobTitle) {
    _appsflyerSdk?.logEvent('job_apply', {
      'af_content_id': jobId.toString(),
      'af_content_type': 'job',
      'af_content': jobTitle ?? '',
    });
  }
}
