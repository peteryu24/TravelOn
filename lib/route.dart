// lib/route.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_on_final/core/presentation/widgets/scaffold_with_bottom_nav.dart';
import 'package:travel_on_final/features/home/presentation/screens/home_screen.dart';
import 'package:travel_on_final/features/search/presentation/screens/search_screen.dart';
import 'package:travel_on_final/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:travel_on_final/features/profile/presentation/screens/profile_screen.dart';

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
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/chat_list',
          builder: (context, state) => ChatListScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
