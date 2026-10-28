import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/services/appsflyer_service.dart';
import 'package:vlr/services/app_router.dart';

import 'firebase/get_fcm_token.dart';
import 'services/init.dart';

import 'firebase_options_primary.dart' as primary_env;

import 'package:firebase_core/firebase_core.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Init().initialize();
  await Firebase.initializeApp(
    name:
        'primaryApp', // Optional: use a name if initializing multiple simultaneously
    options: primary_env.PrimaryFirebaseOptions.currentPlatform,
  );

  await NotificationServices.initialize();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> snackBarKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  initPlatForm() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.none);

    OneSignal.initialize('appId'); //---------------------ADD ONESIGNAL APP ID
    OneSignal.User.pushSubscription.optIn();
    await OneSignal.consentRequired(true);

    await NotificationServices().init();

    OneSignal.Notifications.addForegroundWillDisplayListener(
        (OSNotificationWillDisplayEvent event) {
      event.preventDefault();

      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((OSNotificationClickEvent result) {
      ///TODO:
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log('Current state = $state');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatForm();
    // Initialize AppsFlyer SDK for deep linking & deferred deep linking
    AppsFlyerService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // log("Height : ${MediaQuery.of(context).size.height}");
    // log("weight : ${MediaQuery.of(context).size.width}");
    return ToastificationWrapper(
      child: ScreenUtilInit(
        designSize: Size(432.0, 960.0),

        minTextAdapt: true,
        // splitScreenMode: true,
        child: MaterialApp.router(
          title: AppConstants.appName,
          themeMode: ThemeMode.light,
          theme: CustomTheme.light,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
