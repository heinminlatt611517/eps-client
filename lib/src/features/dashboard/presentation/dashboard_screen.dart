import 'package:eps_client/src/features/agents/presentation/agents_page.dart';
import 'package:eps_client/src/features/more_setting/presentation/more_setting_page.dart';
import 'package:eps_client/src/features/service_status/presentation/service_status_page.dart';
import 'package:eps_client/src/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/dimens.dart';
import '../../home/presentation/home_page.dart';
import '../controller/dashboard_controller.dart';
import '../widget/bottom_navigation_widget.dart';

///notifications count provider
final notificationCountProvider = StateProvider<int>((ref) {
  return 0;
});

class DashboardScreen extends ConsumerStatefulWidget {
  final Widget child;

  const DashboardScreen({required this.child, super.key});

  static final PageController pageController = PageController();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  String homeScreenAppBar() {
    final index = ref.watch(dashboardControllerProvider);
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Agents";
      case 2:
        return "Service Status";
      case 3:
        return "More";
      default:
        return 'Default Appbar Text';
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint("state changed ${state.name}");
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: SizedBox.expand(
          child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: DashboardScreen.pageController,
              onPageChanged: (index) {
                ref
                    .read(dashboardControllerProvider.notifier)
                    .setPosition(index);
              },
              children: const [
                HomePage(),
                AgentsPage(),
                ServiceStatusPage(),
                MoreSettingsPage(),
              ]),
        ),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Color(0xFFe4e4e4), primaryColor: Colors.white),
        child: const BottomNavigationWidget(),
      ),
    );
  }
}
