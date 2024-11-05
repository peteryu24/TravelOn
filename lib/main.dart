import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;  // AuthProvider 숨기기
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_on_final/features/home/data/repositories/home_repository_impl.dart';
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/weather_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_on_final/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:travel_on_final/features/search/data/repositories/travel_repositories_impl.dart';
import 'package:travel_on_final/route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_on_final/firebase_options.dart';
// provider
import 'package:provider/provider.dart';
import 'package:travel_on_final/core/providers/navigation_provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart' as app;  // alias 추가
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
// social_login
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
// DI
import 'package:travel_on_final/features/auth/domain/usecases/kakao_login_usecase.dart';
import 'package:travel_on_final/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:travel_on_final/features/auth/domain/repositories/auth_repository.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  String kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';

  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Navigation
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // Auth 관련 Providers
        Provider<AuthRepository>(
            create: (_) => AuthRepositoryImpl()
        ),

        // Travel 관련 Providers
        ChangeNotifierProvider(
          create: (_) => TravelProvider(
            TravelRepositoryImpl(),
            auth: FirebaseAuth.instance,
          ),
        ),

        // KakaoLogin UseCase
        ProxyProvider<AuthRepository, KakaoLoginUseCase>(
          update: (_, authRepository, __) => KakaoLoginUseCase(authRepository),
        ),

        // Auth Provider
        ChangeNotifierProxyProvider2<KakaoLoginUseCase, TravelProvider, app.AuthProvider>(
          create: (context) => app.AuthProvider(
            context.read<KakaoLoginUseCase>(),
            context.read<TravelProvider>(),
          ),
          update: (context, kakaoLoginUseCase, travelProvider, previous) =>
          previous ?? app.AuthProvider(kakaoLoginUseCase, travelProvider!),
        ),

        // 기타 Providers
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
          create: (_) => ReservationProvider(FirebaseFirestore.instance),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            GetNextTrip(
              HomeRepositoryImpl(FirebaseFirestore.instance),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: MaterialApp.router(
          title: 'Travel On',
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
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