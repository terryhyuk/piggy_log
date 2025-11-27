import 'package:flutter/material.dart';

/// A widget that shakes its child when [isActive] is true.
/// Used for "edit mode" visual feedback (similar to iOS home screen icons shaking).
class AnimatedShake extends StatefulWidget {
  /// The child widget to apply the shake animation to.
  final Widget child;

  /// Whether the shake animation is active.
  final bool isActive;

  const AnimatedShake({
    super.key,
    required this.child,
    required this.isActive,
  });

  @override
  State<AnimatedShake> createState() => _AnimatedShakeState();
}

class _AnimatedShakeState extends State<AnimatedShake>
    with SingleTickerProviderStateMixin {

  // --- property ---
  late AnimationController _controller;
  late Animation<double> _animation;

  // --- Lifecycle ---
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Tween for a small rotation back and forth (like wiggling)
    _animation = Tween(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    // Start animation only if active
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Toggle animation when `isActive` changes
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No animation when inactive
    if (!widget.isActive) return widget.child;
    // Shaking animation
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Transform.rotate(
          angle: _animation.value,
          child: widget.child,
        );
      },
    );
  }

}// END
