import 'package:eps_client/src/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/go_router/go_router_delegate.dart';
import '../controller/dashboard_controller.dart';
import '../presentation/dashboard_screen.dart';

class BottomNavigationWidget extends ConsumerStatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  ConsumerState<BottomNavigationWidget> createState() =>
      _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState
    extends ConsumerState<BottomNavigationWidget> {
  @override
  Widget build(BuildContext context) {
    final position = ref.watch(dashboardControllerProvider);

    return BottomNavigationBar(
      unselectedItemColor: Colors.white,
      selectedItemColor: context.kSecondaryColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      currentIndex: position,
      elevation: 0.0,
      onTap: (index) {
        _onTap(index);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
              size: 30,
              Icons.home,
              color: position == 0 ? context.kSecondaryColor : Colors.white),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
              size: 30,
              Icons.real_estate_agent_outlined,
              color: position == 1 ? context.kSecondaryColor : Colors.white),
          label: 'Agents',
        ),
        BottomNavigationBarItem(
          icon: Icon(
              size: 26,
              Icons.home_repair_service,
              color: position == 2 ? context.kSecondaryColor : Colors.white),
          label: 'Service Status',
        ),
        BottomNavigationBarItem(
          icon: Icon(
              size: 30,
              Icons.more_horiz,
              color: position == 3 ? context.kSecondaryColor : Colors.white),
          label: 'More',
        ),
      ],
    );
  }

  void _onTap(int index) {
    ref.read(dashboardControllerProvider.notifier).setPosition(index);
    DashboardScreen.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go(RoutePath.agents.path);
        break;
      case 2:
        context.go(RoutePath.serviceStatus.path);
        break;
      case 3:
        context.go(RoutePath.moreSetting.path);
        break;
      default:
    }
  }
}
