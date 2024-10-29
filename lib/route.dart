// lib/route.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_on_final/core/presentation/widgets/scaffold_with_bottom_nav.dart';
import 'package:travel_on_final/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';
import 'package:travel_on_final/features/search/presentation/screens/add_package_screen.dart';
import 'package:travel_on_final/features/search/presentation/screens/detail_screens.dart';
import 'package:travel_on_final/features/search/presentation/screens/package_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const DetailScreen(),
        ),
        GoRoute(
          path: '/chat_list',
          builder: (context, state) => ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/add-package',
          builder: (context, state) => const AddPackageScreen(),
        ),
        GoRoute(
          path: '/package-detail/:id',
          builder: (context, state) {
            final package = state.extra as TravelPackage;
            return PackageDetailScreen(package: package);
          },
        ),

      ],
    ),
  ],
);
