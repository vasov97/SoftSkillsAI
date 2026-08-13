import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = [
      _NavItemData(
          'assets/navbar/home.png', 'assets/navbar/home2.png', l10n.home),
      _NavItemData('assets/navbar/practice.png', 'assets/navbar/practice2.png',
          l10n.trainNewSkill),
      _NavItemData('assets/navbar/chart.png', 'assets/navbar/chart2.png',
          l10n.trackProgress),
      _NavItemData(
          'assets/navbar/goal.png', 'assets/navbar/goal2.png', l10n.goals),
      _NavItemData('assets/navbar/book.png', 'assets/navbar/book2.png',
          l10n.savedLessons),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF006FFF),
            Color.fromARGB(149, 184, 210, 244),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        isSelected ? item.activeAsset : item.asset,
                        width: 24,
                        height: 24,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 9,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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
  _NavItemData(this.asset, this.activeAsset, this.label);
}
