import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/core/providers/navigation_provider.dart';
import 'package:travel_on_final/features/home/presentation/widgets/bottom_navigation_bar.dart';

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) {
          return CustomBottomNavigationBar(
            selectedIndex: navigationProvider.currentIndex,
            onItemTapped: (index) {
              navigationProvider.setIndex(index);
              context.go(navigationProvider.getPathForIndex(index));
            },
          );
        },
      ),
    );
  }
}
