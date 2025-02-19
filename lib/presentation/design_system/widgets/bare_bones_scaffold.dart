import 'package:flutter/material.dart';

class BareBonesScaffold extends StatelessWidget {
  const BareBonesScaffold({super.key, required this.body, this.appBar, this.bottomNavigationBar, this.backgroundColor});

  final Widget? body;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBar,
        body: body,
        backgroundColor: backgroundColor,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
