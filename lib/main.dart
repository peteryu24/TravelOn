import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_on_final/features/home/data/repositories/home_repository_impl.dart';
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/weather_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_on_final/features/reservation/presentation/providers/reservation_provider.dart';
import 'package:travel_on_final/features/review/data/repositories/review_repository_impl.dart';
import 'package:travel_on_final/features/review/presentation/provider/review_provider.dart';
import 'package:travel_on_final/features/search/data/repositories/travel_repositories_impl.dart';
import 'package:travel_on_final/route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_on_final/features/auth/domain/usecases/reset_password_usecase.dart';
// firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_on_final/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider;
// provider
import 'package:provider/provider.dart';
import 'package:travel_on_final/core/providers/navigation_provider.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart'
    as app;
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
// DI
import 'package:travel_on_final/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:travel_on_final/features/auth/domain/repositories/auth_repository.dart';
import 'package:travel_on_final/features/gallery/data/repositories/gallery_repository.dart';
import 'package:travel_on_final/features/gallery/presentation/providers/gallery_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate();

  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>.value(value: FirebaseAuth.instance),
        Provider<FirebaseFirestore>.value(value: FirebaseFirestore.instance),

        // Auth 관련 Providers
        ChangeNotifierProvider(
          create: (context) => app.AuthProvider(
            context.read<FirebaseAuth>(),          
            context.read<ResetPasswordUseCase>(),
            context.read<TravelProvider>(),
          ),
        ),
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        ProxyProvider<FirebaseAuth, ResetPasswordUseCase>(
          update: (_, auth, __) => ResetPasswordUseCase(auth),
        ),

        // Travel 관련 Providers
        ChangeNotifierProvider(
          create: (_) => TravelProvider(
            TravelRepositoryImpl(),
            auth: FirebaseAuth.instance,
          ),
        ),

        // 네비게이션 관련 Provider
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // 채팅 관련 Provider
        ChangeNotifierProvider(create: (_) => ChatProvider()),

        // 예약 관련 Provider
        ChangeNotifierProvider(
          create: (_) => ReservationProvider(FirebaseFirestore.instance),
        ),

        // 리뷰 관련 Provider
        ChangeNotifierProvider(
          create: (context) => ReviewProvider(
            ReviewRepositoryImpl(
              context.read<TravelProvider>(),
            ),
          ),
        ),

        // 홈 화면 관련 Provider
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            GetNextTrip(
              HomeRepositoryImpl(FirebaseFirestore.instance),
            ),
          ),
        ),

        // 날씨 관련 Provider
        ChangeNotifierProvider(create: (_) => WeatherProvider()),

        // 갤러리 관련 Provider
        ChangeNotifierProvider(
          create: (context) => GalleryProvider(
            GalleryRepository(),
          ),
        ),
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
