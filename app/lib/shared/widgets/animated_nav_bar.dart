import 'dart:ui';

import 'package:app/core/animation/app_durations.dart';
import 'package:app/core/theme/app_spacing.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NavBarItem {
  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class AnimatedNavBar extends StatelessWidget {
  const AnimatedNavBar({
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppExtendedTheme>()!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding == 0 ? 12 : 8),
      child: ClipRRect(
        borderRadius: AppRadii.borderLg,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: ext.glassSigma, sigmaY: ext.glassSigma),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: theme.navigationBarTheme.backgroundColor?.withAlpha(ext.isDark ? 200 : 220),
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: ext.dividerColor.withAlpha(110)),
              boxShadow: AppShadows.soft(),
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: _NavBarItemWidget(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItemWidget extends StatelessWidget {
  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withAlpha(130);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              width: isSelected ? 52 : 0,
              height: isSelected ? 36 : 0,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(28),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.12 : 1,
                  duration: AppDurations.fast,
                  curve: Curves.easeOutBack,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 23,
                    color: isSelected ? primaryColor : inactiveColor,
                    semanticLabel: item.label,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.fast,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: isSelected ? primaryColor : inactiveColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                  child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

