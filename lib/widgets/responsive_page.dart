import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class ResponsivePage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;
  final double maxWidth;

  const ResponsivePage({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = false,
    this.maxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding:
                padding ??
                EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.xl,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
                ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Align(
                alignment: centerContent
                    ? Alignment.center
                    : Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
