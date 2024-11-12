import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_on_final/features/home/data/models/weather_models.dart';
import 'package:travel_on_final/features/home/presentation/providers/weather_provider.dart';
import 'package:travel_on_final/features/home/presentation/widgets/weather_slider.dart';
import 'weather_slider_test.mocks.dart';

@GenerateMocks([WeatherProvider])
void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  late MockWeatherProvider mockWeatherProvider;

  setUp(() {
    mockWeatherProvider = MockWeatherProvider();
    when(mockWeatherProvider.weatherList).thenReturn([]);
    when(mockWeatherProvider.isLoading).thenReturn(false);
    when(mockWeatherProvider.error).thenReturn(null);
    when(mockWeatherProvider.fetchWeather()).thenAnswer((_) => Future.value());
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        home: ChangeNotifierProvider<WeatherProvider>.value(
          value: mockWeatherProvider,
          child: const WeatherSlider(),
        ),
      ),
    );
  }

  group('WeatherSlider Widget Tests', () {
    testWidgets('shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      // arrange
      when(mockWeatherProvider.isLoading).thenReturn(true);
      when(mockWeatherProvider.error).thenReturn(null);
      when(mockWeatherProvider.weatherList).thenReturn([]);

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error exists',
        (WidgetTester tester) async {
      // arrange
      when(mockWeatherProvider.isLoading).thenReturn(false);
      when(mockWeatherProvider.error).thenReturn('날씨 정보를 불러오는데 실패했습니다.');
      when(mockWeatherProvider.weatherList).thenReturn([]);

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('날씨 정보를 불러오는데 실패했습니다.'), findsOneWidget);
    });

    testWidgets('shows empty message when weather list is empty',
        (WidgetTester tester) async {
      // arrange
      when(mockWeatherProvider.isLoading).thenReturn(false);
      when(mockWeatherProvider.error).thenReturn(null);
      when(mockWeatherProvider.weatherList).thenReturn([]);

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('날씨 정보가 없습니다.'), findsOneWidget);
    });

    testWidgets('displays weather information correctly',
        (WidgetTester tester) async {
      // arrange
      final weatherList = [
        WeatherModel(
          city: '서울',
          temperature: 25.0,
          condition: '맑음',
          windSpeed: 3.0,
          humidity: 60,
          precipitation: 0.0,
        ),
      ];

      when(mockWeatherProvider.isLoading).thenReturn(false);
      when(mockWeatherProvider.error).thenReturn(null);
      when(mockWeatherProvider.weatherList).thenReturn(weatherList);

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('서울'), findsOneWidget);
      expect(find.text('25.0°'), findsOneWidget);
      expect(find.text('3.0m/s'), findsOneWidget);
    });

    testWidgets('shows precipitation when it exists',
        (WidgetTester tester) async {
      // arrange
      final weatherList = [
        WeatherModel(
          city: '서울',
          temperature: 20.0,
          condition: '비',
          windSpeed: 2.0,
          humidity: 80,
          precipitation: 5.0,
        ),
      ];

      when(mockWeatherProvider.isLoading).thenReturn(false);
      when(mockWeatherProvider.error).thenReturn(null);
      when(mockWeatherProvider.weatherList).thenReturn(weatherList);

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text(' 5.0mm'), findsOneWidget);
    });
  });

  tearDown(() {
    // Timer 정리
    mockWeatherProvider.dispose();
  });
}
