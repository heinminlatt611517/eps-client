import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:eps_client/src/fcm/fcm_service.dart';
import 'package:eps_client/src/routing/go_router/go_router_delegate.dart';
import 'package:eps_client/src/utils/fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'src/remote_config/firebase_remote_config.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

final ProviderContainer container = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeDateFormatting('en_US');
  await GetStorage.init();
  await EasyLocalization.ensureInitialized();
  registerErrorHandlers();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('th')],
        path: 'assets/l10n',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

///My App
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterDelegateProvider);
    final themes = ref.watch(remoteThemesProvider);

    ThemeData withFont(ThemeData base) => ThemeData(
      useMaterial3: base.useMaterial3,
      colorScheme: base.colorScheme,
      fontFamily: kJaldi,
    );

    ///fcm initialize
    FCMService().listenForMessages(ref);


    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
      theme: withFont(themes.light),
      darkTheme: withFont(themes.dark),
      themeMode: ThemeMode.system,
    );
  }
}

///error handler
void registerErrorHandlers() {
  /// * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };

  /// * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    return true;
  };

  /// * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('An error occurred'),
        ),
        body: Center(child: Text(details.toString())),
      ),
    );
  };
}

///Page transition builder
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }
}
