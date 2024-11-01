import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
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
  // Load the Kakao Native App Key from the .env file
  String kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';

  // Initialize Kakao SDK with the loaded key
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
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        ProxyProvider<AuthRepository, KakaoLoginUseCase>(
          update: (_, authRepository, __) => KakaoLoginUseCase(authRepository),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<KakaoLoginUseCase>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
          create: (_) => TravelProvider(TravelRepositoryImpl()),
        ),
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
