import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    A gamified budget visualizer that provides emotional feedback through 
//    dynamic asset layering and micro-animations. 
//    Features a lightweight, controller-less animation engine for efficiency.
//
//  * TODO: 
//    - Transition from PNG assets to Lottie or Rive for smoother vector animations.
//    - Refactor the threshold logic into a separate state-machine.
// -----------------------------------------------------------------------------

class BudgetPigWidget extends StatelessWidget {
  /// Expenditure ratio (e.g., 0.5 for 50%)
  final double percent; 

  const BudgetPigWidget({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Allows effects to overflow for a dynamic feel.
        children: [
          // 1. Base Mascot Layer
          _buildPigBody(),
          
          // 2. Conditional Feedback Layer (Hearts, Sweat, or Steam)
          if (percent < 0.5) _buildHappyHearts(),
          if (percent >= 0.5 && percent < 0.7) _buildWorriedSweat(),
          if (percent >= 0.7) _buildAngrySteam(),
        ],
      ),
    );
  }

  /// Determines the mascot's emotional state based on spending thresholds.
  Widget _buildPigBody() {
    String img = 'pig_happy.png';
    if (percent >= 0.7) {
      img = 'pig_angry.png';
    } else if (percent >= 0.5) {
      img = 'pig_worried.png';
    }
    return Image.asset('images/$img', width: 75);
  }

  /// Low-spending state: Sequential rising heart animations.
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

  /// Mid-spending state: Vertical translation for a dripping sweat effect.
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

  /// High-spending state: Pulsating steam effects on both sides.
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

/// Lightweight helper for creating looping animations without AnimationControllers.
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