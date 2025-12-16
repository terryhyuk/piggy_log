import 'package:flutter/material.dart';

/// A widget that shakes its child when [isActive] is true.
/// Handles app lifecycle to pause/resume animation correctly.
class AnimatedShake extends StatefulWidget {
  final Widget child;
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 앱 라이프사이클 옵저버 등록
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _animation = Tween(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 초기 상태에 따라 애니메이션 시작
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint("App Lifecycle State: $state");

    if (state == AppLifecycleState.resumed) {
      // 포그라운드 복귀 시 isActive 상태에 따라 애니메이션 제어
      if (widget.isActive) {
        if (!_controller.isAnimating) {
          _controller.repeat(reverse: true);
          debugPrint("Shake Animation RESUMED.");
        }
      } else {
        if (_controller.isAnimating) {
          _controller.stop();
          _controller.reset();
          debugPrint("Shake Animation STOPPED and RESET.");
        }
      }
    } else if (state == AppLifecycleState.paused) {
      // 백그라운드로 갈 때는 항상 멈춤
      if (_controller.isAnimating) {
        _controller.stop();
        debugPrint("Shake Animation PAUSED.");
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedShake oldWidget) {
    super.didUpdateWidget(oldWidget);

    // isActive 상태 변화 감지
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

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
}

// import 'package:flutter/material.dart';

// /// A widget that shakes its child when [isActive] is true.
// /// Used for "edit mode" visual feedback (similar to iOS home screen icons shaking).
// class AnimatedShake extends StatefulWidget {
//   /// The child widget to apply the shake animation to.
//   final Widget child;

//   /// Whether the shake animation is active.
//   final bool isActive;

//   const AnimatedShake({
//     super.key,
//     required this.child,
//     required this.isActive,
//   });

//   @override
//   State<AnimatedShake> createState() => _AnimatedShakeState();
  
// }

// class _AnimatedShakeState extends State<AnimatedShake>
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {

//   // --- property ---
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   // --- Lifecycle ---
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 250),
//     );
//     _animation = Tween(begin: -0.03, end: 0.03).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
    
//     if (widget.isActive) {
//       _controller.repeat(reverse: true);
//     }
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     print("App Lifecycle State: $state");
    
//     // 페이지로 돌아왔을 때 (활성화되었을 때)
//     if (state == AppLifecycleState.resumed) { 
//       // 현재 위젯이 활성화되어 있지 않은 상태(isActive=false)인데, 
//       // 애니메이션이 돌아가고 있다면 멈추고 리셋합니다.
//       if (!widget.isActive && _controller.isAnimating) {
//         _controller.stop();
//         _controller.reset();
//         print("Shake Animation STOPPED and RESET."); // 👈 멈춤 확인
//       }
//     }
//   }


//   @override
//   void didUpdateWidget(covariant AnimatedShake oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Toggle animation when `isActive` changes
//     if (widget.isActive && !_controller.isAnimating) {
//       _controller.repeat(reverse: true);
//     } else if (!widget.isActive && _controller.isAnimating) {
//       _controller.stop();
//       _controller.reset(); // Reset the animation
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // If not active, just return the child
//     if (!widget.isActive) {
//       return widget.child;
//     }
    
//     // Shaking animation
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, _) {
//         return Transform.rotate(
//           angle: _animation.value, 
//           child: widget.child,
//         );
//       },
//     );
//   }

// }// END
