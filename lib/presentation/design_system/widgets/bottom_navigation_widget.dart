import 'package:flutter_video_feed/core/constants/enums/router_enums.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key, this.child, required this.location});

  final Widget? child;
  final String location;

  @override
  Widget build(BuildContext context) {
    return BareBonesScaffold(bottomNavigationBar: _bottomNavigationBuilder(context, location), body: child);
  }
}

BottomNavigationBar _bottomNavigationBuilder(BuildContext context, String location) {
  return BottomNavigationBar(
    key: ValueKey(location),
    currentIndex: _calculateSelectedIndex(context),
    selectedItemColor: black,
    unselectedItemColor: black54,
    onTap: (index) => _onItemTapped(index, context),
    showSelectedLabels: false,
    showUnselectedLabels: false,
    items: [
      const BottomNavigationBarItem(
        label: '',
        icon: Icon(CupertinoIcons.home, size: 24),
        activeIcon: Icon(CupertinoIcons.home, size: 24),
      ),
      const BottomNavigationBarItem(
        label: '',
        icon: Icon(CupertinoIcons.play_rectangle, size: 24),
        activeIcon: Icon(CupertinoIcons.play_rectangle, size: 24),
      ),
      const BottomNavigationBarItem(
        label: '',
        icon: Icon(CupertinoIcons.person, size: 24),
        activeIcon: Icon(CupertinoIcons.person, size: 24),
      ),
    ],
  );
}

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();

  if (location == RouterEnums.dashboardView.routeName) {
    return 0;
  }
  if (location == RouterEnums.videoFeedView.routeName) {
    return 1;
  }
  if (location == RouterEnums.profileView.routeName) {
    return 2;
  }
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      GoRouter.of(context).go(RouterEnums.dashboardView.routeName);
      break;
    case 1:
      GoRouter.of(context).go(RouterEnums.videoFeedView.routeName);
      break;
    case 2:
      GoRouter.of(context).go(RouterEnums.profileView.routeName);
      break;
  }
}
