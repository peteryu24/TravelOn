// test/features/home/presentation/widgets/next_trip_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/widgets/next_trip_card.dart';
import '../../../../test_helpers/mocks.mocks.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_on_final/core/providers/theme_provider.dart';

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockHomeProvider mockHomeProvider;
  late MockThemeProvider mockThemeProvider;

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockHomeProvider = MockHomeProvider();
    mockThemeProvider = MockThemeProvider();

    when(mockHomeProvider.isLoading).thenReturn(false);
    when(mockHomeProvider.nextTrip).thenReturn(null);
    when(mockAuthProvider.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return EasyLocalization(
      supportedLocales: const [Locale('ko')],
      path: 'test/assets/translations',
      fallbackLocale: const Locale('ko'),
      useOnlyLangCode: true,
      saveLocale: false,
      child: Builder(
        builder: (context) => ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: const Locale('ko'),
            home: MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthProvider>.value(
                    value: mockAuthProvider),
                ChangeNotifierProvider<HomeProvider>.value(
                    value: mockHomeProvider),
                ChangeNotifierProvider<ThemeProvider>.value(
                    value: mockThemeProvider),
              ],
              child: const Scaffold(
                body: Material(
                  child: MediaQuery(
                    data: MediaQueryData(),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: NextTripCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('NextTripCard Widget Tests', () {
    testWidgets('shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      // arrange
      when(mockHomeProvider.isLoading).thenReturn(true);
      when(mockHomeProvider.nextTrip).thenReturn(null);

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

class MockThemeProvider extends Mock implements ThemeProvider {
  @override
  ThemeMode get themeMode => ThemeMode.light;

  @override
  bool get isDarkMode => false;
}
