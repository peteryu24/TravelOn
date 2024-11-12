import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/core/providers/navigation_provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
      ),
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_alt_fill),
          label: '홈',
        ),
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.compass_fill),
          label: '여행상품',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(CupertinoIcons.chat_bubble_2_fill),
              if (navigationProvider.totalUnreadCount > 0)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${navigationProvider.totalUnreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          label: '채팅',
        ),
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_crop_circle_fill),
          label: '마이페이지',
        ),
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
