import 'package:flutter_video_feed/core/constants/enums/router_enum.dart';
import 'package:flutter_video_feed/core/init/router/custom_page_builder_widget.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:flutter_video_feed/presentation/views/dashboard/dashboard_view.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bottom_navigation_widget.dart';
import 'package:flutter_video_feed/presentation/views/profile/profile_view.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/video_feed_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouterEnum.dashboardView.routeName,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder:
            (context, state, child) => customPageBuilderWidget(
              context,
              state,
              BottomNavigationWidget(
                location: state.uri.toString(),
                child: child,
                backgroundColor: state.uri.toString() == RouterEnum.videoFeedView.routeName ? black : null,
              ),
            ),
        routes: [
          GoRoute(
            path: RouterEnum.dashboardView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(context, state, const DashboardView()),
          ),
          GoRoute(
            path: RouterEnum.videoFeedView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(context, state, const VideoFeedView()),
          ),
          GoRoute(
            path: RouterEnum.profileView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(context, state, const ProfileView()),
          ),
        ],
      ),
    ],
  );
}
