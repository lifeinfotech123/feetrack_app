import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vlr/data/models/job_post_model.dart';
import 'package:vlr/main.dart';
import 'package:vlr/services/appsflyer_service.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/views/screens/auth_screens/register/register_screen.dart';
import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';
import 'package:vlr/views/screens/dashboard/job/job_detail_screen.dart';
import 'package:vlr/views/screens/splash_screen/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String jobDetail = '/job/:id';

  /// Extract Job ID and Referral Code from any incoming deep link or URI
  static ({int? jobId, String? referralCode}) parseDeepLinkUri(Uri uri) {
    int? jobId;
    String? referralCode = uri.queryParameters['referral'] ??
        uri.queryParameters['deep_link_sub3'] ??
        uri.queryParameters['af_sub3'];

    // 1. Check deep_link_value query parameter (OneLink format e.g. job_3 or 3)
    final deepLinkValue = uri.queryParameters['deep_link_value'] ??
        uri.queryParameters['af_dp'] ??
        uri.queryParameters['link'];
    if (deepLinkValue != null && deepLinkValue.isNotEmpty) {
      if (deepLinkValue.contains('job_')) {
        final match = RegExp(r'job_(\d+)').firstMatch(deepLinkValue);
        if (match != null) jobId = int.tryParse(match.group(1)!);
      } else if (int.tryParse(deepLinkValue) != null) {
        jobId = int.tryParse(deepLinkValue);
      }
    }

    // 2. Check custom scheme feetrack://job/3 or feetrack://3
    if (jobId == null && uri.scheme == 'feetrack') {
      if (uri.host == 'job' && uri.pathSegments.isNotEmpty) {
        jobId = int.tryParse(uri.pathSegments.first);
      } else if (int.tryParse(uri.host) != null) {
        jobId = int.tryParse(uri.host);
      }
    }

    // 3. Check path segment /job/3
    if (jobId == null && uri.path.contains('/job/')) {
      final match = RegExp(r'/job/(\d+)').firstMatch(uri.path);
      if (match != null) jobId = int.tryParse(match.group(1)!);
    }

    return (jobId: jobId, referralCode: referralCode);
  }

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: splash,
    redirect: (BuildContext context, GoRouterState state) {
      final uri = state.uri;
      dev.log('GoRouter redirect check: uri=$uri, path=${uri.path}', name: 'APP_ROUTER');

      final parsed = parseDeepLinkUri(uri);
      final jobId = parsed.jobId;
      final referralCode = parsed.referralCode;

      // 1. If deep link contains referral code or job ID -> save to SharedPreferences immediately!
      if (referralCode != null && referralCode.isNotEmpty) {
        AppsFlyerService.saveReferralToPrefs(referralCode, jobId: jobId);
      }

      // 2. If incoming URI is an external URL (OneLink or custom scheme feetrack://)
      if (uri.scheme == 'feetrack' || (uri.host.isNotEmpty && uri.host != 'localhost')) {
        final isLoggedIn = AppsFlyerService.checkIsLoggedIn();
        dev.log('External URI handled -> jobId: $jobId, referral: $referralCode, isLoggedIn: $isLoggedIn', name: 'APP_ROUTER');

        final refQuery = (referralCode != null && referralCode.isNotEmpty)
            ? '?referral=${Uri.encodeComponent(referralCode)}'
            : '';

        if (isLoggedIn) {
          if (jobId != null && jobId > 0) {
            return '/job/$jobId$refQuery';
          } else {
            return '/job$refQuery';
          }
        } else {
          // NOT logged in -> save pending and redirect to register
          if (jobId != null && jobId > 0) {
            AppsFlyerService.setPendingJob(jobId, referralCode);
          }
          return '/register$refQuery';
        }
      }

      // 3. If standard in-app route /job/:id is navigated to while NOT logged in
      if (uri.path.startsWith('/job')) {
        final isLoggedIn = AppsFlyerService.checkIsLoggedIn();
        if (!isLoggedIn) {
          if (jobId != null && jobId > 0) {
            AppsFlyerService.setPendingJob(jobId, referralCode);
          }
          final refQuery = (referralCode != null && referralCode.isNotEmpty)
              ? '?referral=${Uri.encodeComponent(referralCode)}'
              : '';
          return '/register$refQuery';
        }
      }

      return null;
    },
    errorBuilder: (context, state) {
      dev.log('GoRouter error: ${state.error}', name: 'APP_ROUTER');
      // If any unhandled location arrives, fallback to SplashScreen safely
      return const SplashScreen();
    },
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) {
          final referralCode = state.uri.queryParameters['referral'] ?? state.uri.queryParameters['deep_link_sub3'];
          return RegisterScreen(
            referralCode: (referralCode != null && referralCode.isNotEmpty)
                ? referralCode
                : null,
          );
        },
      ),
      GoRoute(
        path: jobDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final jobId = int.tryParse(idStr ?? '');
          final referralCode = state.uri.queryParameters['referral'] ?? state.uri.queryParameters['deep_link_sub3'];
          return JobDetailScreen(
            job: JobPostModel(id: jobId),
            referralCode: (referralCode != null && referralCode.isNotEmpty)
                ? referralCode
                : null,
          );
        },
      ),
      GoRoute(
        path: '/job',
        builder: (context, state) {
          final referralCode = state.uri.queryParameters['referral'] ?? state.uri.queryParameters['deep_link_sub3'];
          return JobDetailScreen(
            job: JobPostModel(),
            referralCode: (referralCode != null && referralCode.isNotEmpty)
                ? referralCode
                : null,
          );
        },
      ),
    ],
  );

  /// Helper for Deep Linking Navigation to Job Detail
  static void goToJob(int jobId, {String? referralCode}) {
    final query = (referralCode != null && referralCode.isNotEmpty)
        ? '?referral=${Uri.encodeComponent(referralCode)}'
        : '';
    if (jobId > 0) {
      router.push('/job/$jobId$query');
    } else {
      router.push('/job$query');
    }
  }

  /// Helper for Deep Linking Navigation to Job Detail by Referral Code
  static void goToJobByReferral(String referralCode) {
    router.push('/job?referral=${Uri.encodeComponent(referralCode)}');
  }

  /// Helper for Deep Linking Navigation to Register with Referral Code
  static void goToRegister({String? referralCode}) {
    final query = (referralCode != null && referralCode.isNotEmpty)
        ? '?referral=${Uri.encodeComponent(referralCode)}'
        : '';
    router.push('/register$query');
  }

  /// Navigation helpers
  static void goToLogin() {
    router.go(login);
  }

  static void goToDashboard() {
    router.go(dashboard);
  }
}
