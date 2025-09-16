import 'package:eps_client/src/features/agent_details/presentation/agent_details_page.dart';
import 'package:eps_client/src/features/agents/presentation/agents_page.dart';
import 'package:eps_client/src/features/more_setting/presentation/more_setting_page.dart';
import 'package:eps_client/src/features/service_request/presentation/service_request_page.dart';
import 'package:eps_client/src/features/service_status/presentation/service_status_page.dart';
import 'package:eps_client/src/features/upload_documents/presentation/upload_documents_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/home/presentation/home_page.dart';
import '../../utils/secure_storage.dart';
import '../route_error_screen/route_error_screen.dart';

part 'go_router_delegate.g.dart';

enum RoutePath {
  initial(path: '/'),
  root(path: "root"),
  home(path: "home"),
  login(path: '/login'),
  agents(path: '/agents'),
  serviceRequest(path: '/serviceRequest'),
  serviceStatus(path: '/serviceStatus'),
  agentDetail(path: '/agentDetail'),
  uploadDocuments(path: '/uploadDocuments'),
  moreSetting(path: '/moreSetting');

  const RoutePath({required this.path});

  final String path;
}

@riverpod
GoRouter goRouterDelegate(GoRouterDelegateRef ref) {
  final GlobalKey<NavigatorState> rootNavigator = GlobalKey(debugLabel: 'root');
  final GlobalKey<NavigatorState> shellNavigator = GlobalKey(
    debugLabel: 'shell',
  );

  final authStatus = ref.watch(getAuthStatusProvider).value;
  debugPrint("AuthStatus:::$authStatus");
  bool isDuplicate = false;

  return GoRouter(
    navigatorKey: rootNavigator,
    initialLocation: '/',
    routes: [
      // ///login page
      // GoRoute(
      //   path: RoutePath.login.path,
      //   parentNavigatorKey: rootNavigator,
      //   pageBuilder: (context, state) {
      //     return buildPageWithDefaultTransition(
      //         context: context,
      //         state: state,
      //         child: LoginPage(
      //           key: state.pageKey,
      //         ));
      //   },
      // ),
      //
      // ///home page
      ///dashboard page
      ShellRoute(
        navigatorKey: shellNavigator,
        builder: (context, state, child) =>
            DashboardScreen(key: state.pageKey, child: child),
        routes: [
          ///home page
          GoRoute(
            path: '/',
            name: RoutePath.home.name,
            pageBuilder: (context, state) {
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: SafeArea(child: HomePage(key: state.pageKey)),
              );
            },
          ),

          ///agents page
          GoRoute(
            parentNavigatorKey: shellNavigator,
            path: RoutePath.agents.path,
            name: RoutePath.agents.name,
            pageBuilder: (context, state) {
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: AgentsPage(key: state.pageKey),
              );
            },
          ),

          ///service status page
          GoRoute(
            path: RoutePath.serviceStatus.path,
            name: RoutePath.serviceStatus.name,
            parentNavigatorKey: shellNavigator,
            pageBuilder: (context, state) {
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: ServiceStatusPage(key: state.pageKey),
              );
            },
          ),

          ///more setting page
          GoRoute(
            path: RoutePath.moreSetting.path,
            name: RoutePath.moreSetting.name,
            parentNavigatorKey: shellNavigator,
            pageBuilder: (context, state) {
              return buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: MoreSettingsPage(key: state.pageKey),
              );
            },
          ),
        ],
      ),

      ///service request page
      GoRoute(
        path: RoutePath.serviceRequest.path,
        name: RoutePath.serviceRequest.name,
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ServiceRequestPage(key: state.pageKey),
          );
        },
      ),

      ///agent details page
      GoRoute(
        path: RoutePath.agentDetail.path,
        name: RoutePath.agentDetail.name,
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: AgentDetailsPage(key: state.pageKey),
          );
        },
      ),

      ///upload document page
      GoRoute(
        path: RoutePath.uploadDocuments.path,
        name: RoutePath.uploadDocuments.name,
        pageBuilder: (context, state) {
          return buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: UploadDocumentsPage(key: state.pageKey),
          );
        },
      ),
    ],
    errorBuilder: (context, state) =>
        RouteErrorScreen(errorMsg: state.error.toString(), key: state.pageKey),
  );
}

///custom transition page
CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
  );
}
