import 'package:flutter/material.dart';

///
/// BuildArrow Widget
/// 
/// Purpose: 
/// A reusable chevron icon used for navigation or list item indicators.
/// Automatically adjusts color based on the system theme (Light/Dark mode).
///
class BuildArrow extends StatelessWidget {
  const BuildArrow({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current theme to support dynamic color switching
    final theme = Theme.of(context);

    return Icon(
      Icons.arrow_forward_ios,
      size: 16,
      // 'onSurface' color automatically switches between black (light) and white (dark)
      color: theme.colorScheme.onSurface,
      weight: 700,
    );
  }
}