import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/theme.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.hairline, width: 1)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          items: [
            _buildItem(0, 'REPORTS', navigationShell.currentIndex == 0),
            _buildItem(1, 'NEW', navigationShell.currentIndex == 1),
            _buildItem(2, 'MAP', navigationShell.currentIndex == 2),
            _buildItem(3, 'PROFILE', navigationShell.currentIndex == 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildItem(int index, String label, bool isActive, {bool hasBadge = false}) {
    // Custom label with thin underline if active
    Widget textWidget = Text(label);

    if (hasBadge) {
      textWidget = Badge(
        backgroundColor: AppTheme.accent,
        child: textWidget,
      );
    }

    final labelWidget = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        textWidget,
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 2),
            height: 1,
            width: 24,
            color: AppTheme.text,
          ),
      ],
    );

    return BottomNavigationBarItem(
      icon: labelWidget,
      label: '', 
    );
  }
}
