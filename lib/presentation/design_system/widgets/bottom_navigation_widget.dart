import 'package:flutter_video_feed/core/constants/enums/router_enums.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    backgroundColor: white,
    currentIndex: _calculateSelectedIndex(context),
    selectedItemColor: blue,
    onTap: (index) => _onItemTapped(index, context),
    items: [
      BottomNavigationBarItem(
        label: AppLocalizations.of(context)!.dashboard,
        icon: const Icon(CupertinoIcons.home, size: 20),
        activeIcon: const Icon(CupertinoIcons.home, size: 20),
      ),
      BottomNavigationBarItem(
        label: AppLocalizations.of(context)!.search,
        icon: const Icon(CupertinoIcons.search, size: 20),
        activeIcon: const Icon(CupertinoIcons.search, size: 20),
      ),
      BottomNavigationBarItem(
        label: AppLocalizations.of(context)!.profile,
        icon: const Icon(CupertinoIcons.person, size: 20),
        activeIcon: const Icon(CupertinoIcons.person, size: 20),
      ),
    ],
  );
}

int _calculateSelectedIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.toString();

  if (location == RouterEnums.dashboardView.routeName) {
    return 0;
  }
  if (location == RouterEnums.searchView.routeName) {
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
      GoRouter.of(context).go(RouterEnums.searchView.routeName);
      break;
    case 2:
      GoRouter.of(context).go(RouterEnums.profileView.routeName);
      break;
  }
}
