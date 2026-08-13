import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/user.dart';
import 'package:softai/screens/goals_screen.dart';
import 'package:softai/screens/new_skill_screen.dart';
import 'package:softai/screens/profile_screen.dart';
import 'package:softai/screens/saved_lessons_screen.dart';
import 'package:softai/screens/track_progress_screen.dart';

class MainScreen extends StatefulWidget {
  final UserModel user;
  final int initialIndex;

  const MainScreen({
    super.key,
    required this.user,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final pages = [
      ProfileScreen(user: widget.user),
      NewSkillScreen(user: widget.user),
      TrackProgressScreen(),
      GoalsScreen(),
      SavedLessonsScreen(user: widget.user),
    ];

    final navItems = [
      _NavItemData(
        asset: 'assets/navbar/home.png',
        activeAsset: 'assets/navbar/home2.png',
        label: l10n.home,
      ),
      _NavItemData(
        asset: 'assets/navbar/practice.png',
        activeAsset: 'assets/navbar/practice2.png',
        label: l10n.trainNewSkill,
      ),
      _NavItemData(
        asset: 'assets/navbar/chart.png',
        activeAsset: 'assets/navbar/chart2.png',
        label: l10n.trackProgress,
      ),
      _NavItemData(
        asset: 'assets/navbar/goal.png',
        activeAsset: 'assets/navbar/goal2.png',
        label: l10n.goals,
      ),
      _NavItemData(
        asset: 'assets/navbar/book.png',
        activeAsset: 'assets/navbar/book2.png',
        label: l10n.savedLessons,
      ),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: pages[_currentIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF006FFF),
                Color.fromARGB(129, 0, 110, 255),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = index == _currentIndex;
                  return _NavItem(
                    asset: isSelected ? item.activeAsset : item.asset,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _currentIndex = index);
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String asset;
  final String activeAsset;
  final String label;

  const _NavItemData({
    required this.asset,
    required this.activeAsset,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.asset,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              width: 24,
              height: 24,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
