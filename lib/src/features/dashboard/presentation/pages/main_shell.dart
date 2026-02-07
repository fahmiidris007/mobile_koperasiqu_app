import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/glass_nav_bar.dart';

/// Main shell with bottom navigation for authenticated screens
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/savings');
        break;
      case 2:
        context.go('/shopping');
        break;
      case 3:
        context.go('/ppob');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update current index based on location
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) {
      _currentIndex = 0;
    } else if (location.startsWith('/savings')) {
      _currentIndex = 1;
    } else if (location.startsWith('/shopping')) {
      _currentIndex = 2;
    } else if (location.startsWith('/ppob')) {
      _currentIndex = 3;
    }

    return SimpleGradientBackground(
      child: Stack(
        children: [
          // Main content
          Positioned.fill(child: widget.child),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              items: const [
                GlassNavBarItem(icon: Icons.home_rounded, label: 'Beranda'),
                GlassNavBarItem(icon: Icons.savings_rounded, label: 'Tabungan'),
                GlassNavBarItem(
                  icon: Icons.shopping_bag_rounded,
                  label: 'Belanja',
                ),
                GlassNavBarItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'PPOB',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
