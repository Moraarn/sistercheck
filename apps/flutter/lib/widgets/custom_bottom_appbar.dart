import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomAppBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavBarItem(
        index: 0,
        currentIndex: currentIndex,
        label: 'Dashboard',
        filledIcon: CupertinoIcons.house_fill,
        outlinedIcon: CupertinoIcons.house,
        onTap: onTap,
      ),
      _NavBarItem(
        index: 1,
        currentIndex: currentIndex,
        label: 'Patients',
        filledIcon: CupertinoIcons.person_2_fill,
        outlinedIcon: CupertinoIcons.person_2,
        onTap: onTap,
      ),
      _NavBarItem(
        index: 2,
        currentIndex: currentIndex,
        label: 'Crystal AI',
        filledIcon: CupertinoIcons.chat_bubble_2_fill,
        outlinedIcon: CupertinoIcons.chat_bubble_2,
        onTap: onTap,
      ),
      _NavBarItem(
        index: 3,
        currentIndex: currentIndex,
        label: 'Colleagues',
        filledIcon: CupertinoIcons.group_solid,
        outlinedIcon: CupertinoIcons.group,
        onTap: onTap,
      ),
      _NavBarItem(
        index: 4,
        currentIndex: currentIndex,
        label: 'Profile',
        filledIcon: CupertinoIcons.person_crop_circle_fill,
        outlinedIcon: CupertinoIcons.person_crop_circle,
        onTap: onTap,
      ),
    ];

    return BottomAppBar(
      height: 60,
      // color: Colors.transparent,
      shape: const CircularNotchedRectangle(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String label;
  final IconData filledIcon;
  final IconData outlinedIcon;
  final ValueChanged<int> onTap;

  const _NavBarItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.filledIcon,
    required this.outlinedIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color =
        isActive
            ? Theme.of(context).primaryColor
            : Theme.of(context).iconTheme.color;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? filledIcon : outlinedIcon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
