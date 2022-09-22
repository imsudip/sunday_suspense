import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sunday_suspense/screens/historypage.dart';
import 'categorypage.dart';
import 'homepage.dart';
import '../ui/app_colors.dart';
import '../widgets/art_glass_overlay.dart';

import '../widgets/miniplayer.dart';

class RootWidget extends StatefulWidget {
  const RootWidget({super.key});

  @override
  State<RootWidget> createState() => _RootWidgetState();
}

class _RootWidgetState extends State<RootWidget> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const HomePageScreen(),
    const CategoryPageScreen(),
    const HistoryPageScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: ArtGlassSmall(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayer(),
            DotNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() {
                _selectedIndex = index;
              }),
              marginR: const EdgeInsets.symmetric(vertical: 8),
              paddingR: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
              // enableFloatingNavBar: false,
              backgroundColor: Colors.transparent,
              items: [
                DotNavigationBarItem(
                  icon: const Icon(Iconsax.home),
                  selectedColor: AppColors.primaryWhiteColor,
                  unselectedColor: AppColors.textSecondaryColor,
                ),
                DotNavigationBarItem(
                  icon: const Icon(Iconsax.category),
                  selectedColor: AppColors.primaryWhiteColor,
                  unselectedColor: AppColors.textSecondaryColor,
                ),
                DotNavigationBarItem(
                  icon: const Icon(Iconsax.save_2),
                  selectedColor: AppColors.primaryWhiteColor,
                  unselectedColor: AppColors.textSecondaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
