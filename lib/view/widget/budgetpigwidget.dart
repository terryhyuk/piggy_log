import 'package:flutter/material.dart';

/// A widget that displays an animated pig character whose expression 
/// and effects change based on the budget consumption percentage.
///
/// Thresholds:
/// - < 50%: Happy state with floating hearts.
/// - 50% ~ 70%: Worried state with a sweat mark.
/// - >= 70%: Angry state with steam effects.
class BudgetPigWidget extends StatelessWidget {
  final double percent; // Expenditure ratio (0.0 to 1.0 or more)

  const BudgetPigWidget({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Allows effects to float outside the 90x90 box
        children: [
          // 1. Core Character Body
          _buildPigBody(),
          
          // 2. Conditional Animation Layers
          if (percent < 0.5) _buildHappyHearts(),
          if (percent >= 0.5 && percent < 0.7) _buildWorriedSweat(),
          if (percent >= 0.7) _buildAngrySteam(),
        ],
      ),
    );
  }

  /// Determines the pig's image based on the spending threshold.
  Widget _buildPigBody() {
    String img = 'pig_happy.png';
    if (percent >= 0.7) {
      img = 'pig_angry.png';
    } else if (percent >= 0.5) {
      img = 'pig_worried.png';
    }
    return Image.asset('images/$img', width: 75);
  }

  /// Floating heart animation for the "Happy" state (< 50%).
  Widget _buildHappyHearts() {
    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(3, (i) => 
        _InfiniteAnimation(
          duration: Duration(milliseconds: 1200 + (i * 400)),
          builder: (value) => Positioned(
            bottom: 60 + (value * 40),
            left: 10 + (i * 25),
            child: Opacity(
              opacity: (1.0 - value).clamp(0.0, 1.0),
              child: Image.asset('images/heart.png', width: 22),
            ),
          ),
        ),
      ),
    );
  }

  /// Sweat/Mark animation for the "Worried" state (50% - 70%).
  Widget _buildWorriedSweat() {
    return _InfiniteAnimation(
      duration: const Duration(milliseconds: 800),
      builder: (value) => Positioned(
        top: 15,
        right: -5,
        child: Transform.translate(
          offset: Offset(0, value * 5),
          child: Image.asset('images/mark.png', width: 30),
        ),
      ),
    );
  }

  /// Steam animation for the "Angry" state (>= 70%).
  Widget _buildAngrySteam() {
    return _InfiniteAnimation(
      duration: const Duration(milliseconds: 500),
      builder: (value) => Stack(
        clipBehavior: Clip.none,
        children: [
          _buildSteamEffect(value, isLeft: true),
          _buildSteamEffect(value, isLeft: false),
        ],
      ),
    );
  }

  /// Helper to create individual steam positioned elements.
  Widget _buildSteamEffect(double value, {required bool isLeft}) {
    return Positioned(
      bottom: 28,
      left: isLeft ? 10 : null,
      right: isLeft ? null : 10,
      child: Transform.scale(
        scale: 0.8 + (value * 0.5), 
        child: Opacity(
          opacity: (1.0 - value).clamp(0.0, 1.0),
          child: Image.asset('images/steam.png', width: 25),
        ),
      ),
    );
  }
}

/// A helper widget that creates an infinite loop animation 
/// by resetting the target value upon completion.
class _InfiniteAnimation extends StatefulWidget {
  final Widget Function(double value) builder;
  final Duration duration;

  const _InfiniteAnimation({required this.builder, required this.duration});

  @override
  State<_InfiniteAnimation> createState() => _InfiniteAnimationState();
}

class _InfiniteAnimationState extends State<_InfiniteAnimation> {
  double _target = 1.0;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _target),
      duration: _target == 0 ? Duration.zero : widget.duration,
      onEnd: () {
        // Use Future.microtask to avoid "setState() or markNeedsBuild() called during build" error
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _target = (_target == 1.0) ? 0.0 : 1.0;
            });
          }
        });
      },
      builder: (context, value, child) => widget.builder(value.clamp(0.0, 1.0)),
    );
  }
}