// test/features/home/presentation/widgets/next_trip_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/home/domain/entities/next_trip_entity.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/presentation/widgets/next_trip_card.dart';
import '../../../../test_helpers/mocks.mocks.dart'; // 수정된 import

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockHomeProvider mockHomeProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockHomeProvider = MockHomeProvider();

    // 기본 stub 설정을 setUp에서 수행
    when(mockHomeProvider.isLoading).thenReturn(false);
    when(mockHomeProvider.nextTrip).thenReturn(null);
    when(mockAuthProvider.currentUser).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
            ChangeNotifierProvider<HomeProvider>.value(value: mockHomeProvider),
          ],
          child: const Scaffold(body: NextTripCard()),
        ),
      ),
    );
  }

  group('NextTripCard Widget Tests', () {
    testWidgets('shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      // arrange
      when(mockHomeProvider.isLoading).thenReturn(true);

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows next trip info when trip exists',
        (WidgetTester tester) async {
      // arrange
      final nextTrip = NextTripEntity(
        packageTitle: '부산 여행',
        tripDate: DateTime.now().add(const Duration(days: 5)),
        dDay: 5,
        isTodayTrip: false,
      );

      when(mockHomeProvider.isLoading).thenReturn(false);
      when(mockHomeProvider.nextTrip).thenReturn(nextTrip);
      when(mockAuthProvider.currentUser).thenReturn(
        UserModel(id: '1', name: '테스트 유저', email: 'test@test.com'),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // 추가

      // assert
      expect(find.text('테스트 유저님,'), findsOneWidget);
      expect(find.text('부산 여행까지\nD-5 남았습니다!'), findsOneWidget);
    });

    // ... 나머지 테스트 케이스들도 같은 패턴으로 수정
  });
}
