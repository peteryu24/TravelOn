import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:travel_on_final/firebase_options.dart';

// Providers
import 'package:provider/provider.dart';
import 'package:travel_on_final/core/providers/navigation_provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart'
    as app;
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:travel_on_final/features/guide/presentation/provider/guide_ranking_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/weather_provider.dart';
import 'package:travel_on_final/features/notification/presentation/providers/notification_provider.dart';
import 'package:travel_on_final/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:travel_on_final/features/gallery/presentation/providers/gallery_provider.dart';

// Repositories & UseCases
import 'package:travel_on_final/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:travel_on_final/features/auth/domain/repositories/auth_repository.dart';
import 'package:travel_on_final/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:travel_on_final/features/home/data/repositories/home_repository_impl.dart';
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart';
import 'package:travel_on_final/features/review/data/repositories/review_repository_impl.dart';
import 'package:travel_on_final/features/search/data/repositories/travel_repositories_impl.dart';
import 'package:travel_on_final/features/gallery/data/repositories/gallery_repository.dart';

// Router
import 'package:travel_on_final/route.dart';

import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    debugPrint('Using Skia rendering');
  }
  await EasyLocalization.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // 네이버 맵 SDK 초기화
  await NaverMapSdk.instance.initialize(
    clientId: 'j3gnaneqmd',
    onAuthFailed: (e) => print("네이버맵 인증 실패: $e"),
  );

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_KEY'] ?? '',
  );

  // FCM 초기화 및 권한 설정
  final messaging = FirebaseMessaging.instance;
  if (Platform.isIOS) {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  // Shared Preferences 초기화
  await SharedPreferences.getInstance();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ko', 'KR'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Firebase 서비스 프로바이더
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),
        Provider<FirebaseMessaging>.value(value: FirebaseMessaging.instance),

        // Repositories
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        Provider<GalleryRepository>(create: (_) => GalleryRepository()),

        // Core Providers
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),

        // Auth 및 Travel 관련 Providers
        ProxyProvider<FirebaseAuth, ResetPasswordUseCase>(
          update: (_, auth, __) => ResetPasswordUseCase(auth),
        ),
        ChangeNotifierProvider(
          create: (_) => TravelProvider(
            TravelRepositoryImpl(),
            auth: FirebaseAuth.instance,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => app.AuthProvider(
            context.read<FirebaseAuth>(),
            context.read<ResetPasswordUseCase>(),
            context.read<TravelProvider>(),
          ),
        ),

        // Feature Providers
        ChangeNotifierProvider(
          create: (context) => ChatProvider(context.read<NavigationProvider>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ReservationProvider(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(
          create: (context) => ReviewProvider(
            ReviewRepositoryImpl(context.read<TravelProvider>()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            GetNextTrip(HomeRepositoryImpl(FirebaseFirestore.instance)),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              GalleryProvider(context.read<GalleryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => GuideRankingProvider(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            FirebaseFirestore.instance,
            FirebaseMessaging.instance,
            context.read<NavigationProvider>(), // NavigationProvider 주입
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp.router(
          title: 'Travel On',
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
                .copyWith(secondary: Colors.blueAccent),
          ),
        ),
      ),
    );
  }
}

// 백그라운드 메시지 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}
