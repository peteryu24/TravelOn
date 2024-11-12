import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_on_final/features/notification/presentation/providers/notification_provider.dart';
import 'package:travel_on_final/features/notification/presentation/screens/notification_center_screen.dart';
import 'notification_badge_test.mocks.dart';

@GenerateMocks([NotificationProvider])
void main() {
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  late MockNotificationProvider mockNotificationProvider;

  setUp(() {
    mockNotificationProvider = MockNotificationProvider();
    when(mockNotificationProvider.unreadCount).thenReturn(0);
    when(mockNotificationProvider.isLoading).thenReturn(false);
    when(mockNotificationProvider.error).thenReturn(null);
    when(mockNotificationProvider.notifications).thenReturn([]);
    when(mockNotificationProvider.loadNotifications())
        .thenAnswer((_) => Future.value());
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        home: ChangeNotifierProvider<NotificationProvider>.value(
          value: mockNotificationProvider,
          child: Scaffold(
            appBar: AppBar(
              actions: [
                Stack(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider<
                                  NotificationProvider>.value(
                                value: mockNotificationProvider,
                                child: const NotificationCenterScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, provider, _) {
                        if (provider.unreadCount == 0) {
                          return const SizedBox.shrink();
                        }
                        return Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              provider.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('notification icon is always visible',
      (WidgetTester tester) async {
    // arrange
    when(mockNotificationProvider.unreadCount).thenReturn(0);

    // act
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationProvider>.value(
        value: mockNotificationProvider,
        child: createWidgetUnderTest(),
      ),
    );

    // assert
    expect(find.byIcon(Icons.notifications), findsOneWidget);
  });

  testWidgets('badge is not shown when unread count is 0',
      (WidgetTester tester) async {
    // arrange
    when(mockNotificationProvider.unreadCount).thenReturn(0);

    // act
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationProvider>.value(
        value: mockNotificationProvider,
        child: createWidgetUnderTest(),
      ),
    );

    // assert
    expect(find.text('0'), findsNothing);
  });

  testWidgets('badge shows correct unread count', (WidgetTester tester) async {
    // arrange
    when(mockNotificationProvider.unreadCount).thenReturn(5);

    // act
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationProvider>.value(
        value: mockNotificationProvider,
        child: createWidgetUnderTest(),
      ),
    );

    // assert
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('tapping notification icon navigates to notification center',
      (WidgetTester tester) async {
    // arrange
    when(mockNotificationProvider.unreadCount).thenReturn(0);

    // act
    await tester.pumpWidget(
      ChangeNotifierProvider<NotificationProvider>.value(
        value: mockNotificationProvider,
        child: createWidgetUnderTest(),
      ),
    );

    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    // assert
    expect(find.byType(NotificationCenterScreen), findsOneWidget);
  });
}
