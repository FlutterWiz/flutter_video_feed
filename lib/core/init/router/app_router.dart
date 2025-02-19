import 'package:flutter_video_feed/core/constants/enums/router_enums.dart';
import 'package:flutter_video_feed/core/init/router/custom_page_builder_widget.dart';
import 'package:flutter_video_feed/presentation/views/auth/sign_in/sign_in_view.dart';
import 'package:flutter_video_feed/presentation/views/auth/sign_up/sign_up_view.dart';
import 'package:flutter_video_feed/presentation/views/dashboard/dashboard_view.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bottom_navigation_widget.dart';
import 'package:flutter_video_feed/presentation/views/profile/profile_view.dart';
import 'package:flutter_video_feed/presentation/views/search/search_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouterEnums.signInView.routeName,
    routes: [
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouterEnums.signUpView.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(context, state, const SignUpView()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouterEnums.signInView.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(context, state, const SignInView()),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder:
            (context, state, child) => customPageBuilderWidget(
              context,
              state,
              BottomNavigationWidget(location: state.uri.toString(), child: child),
            ),
        routes: [
          GoRoute(
            path: RouterEnums.dashboardView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(context, state, const DashboardView()),
          ),
          GoRoute(
            path: RouterEnums.searchView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(context, state, const SearchView()),
          ),
          GoRoute(
            path: RouterEnums.profileView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(context, state, const ProfileView()),
          ),
        ],
      ),
    ],
  );
}
