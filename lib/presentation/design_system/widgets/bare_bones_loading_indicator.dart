import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BareBonesLoadingIndicator {
  final BuildContext _context;

  void hide() {
    _context.pop();
  }

  void show() {
    showDialog(
      context: _context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (_) => const LoadingIndicator(),
    );
  }

  BareBonesLoadingIndicator._create(this._context);

  factory BareBonesLoadingIndicator.of(BuildContext context) {
    return BareBonesLoadingIndicator._create(context);
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.1)),
      child: Center(
        child: Stack(
          children: [
            Align(child: SizedBox(height: size.height, width: size.width)),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
