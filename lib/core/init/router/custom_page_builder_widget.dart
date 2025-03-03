import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef CustomPageBuilderWidget =
    CustomTransitionPage<void> Function(BuildContext context, GoRouterState state, Widget child);

CustomPageBuilderWidget customPageBuilderWidget = (BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    transitionDuration: Duration.zero,
  );
};
