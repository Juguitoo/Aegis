import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileView;
  final Widget desktopView;

  const ResponsiveLayout({
    super.key,
    required this.mobileView,
    required this.desktopView,
  });

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isMobile = shortestSide < 600;

    if (isMobile) {
      return mobileView;
    } else {
      return desktopView;
    }
  }
}
