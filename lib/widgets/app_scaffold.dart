import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget? child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;

  const AppScaffold({
    super.key,
    this.child,
    this.appBar,
    this.floatingActionButton,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.jpg', // <- your background asset
            fit: BoxFit.cover,
          ),
        ),

        // Main content — make scaffold background transparent so
        // underlying image shows through
        Scaffold(
          backgroundColor: Colors
              .transparent, // important: let the image show through scaffold
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: Padding(
            padding: padding,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
