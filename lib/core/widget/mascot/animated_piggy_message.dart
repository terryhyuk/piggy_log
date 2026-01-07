import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Provides dynamic visual feedback through a bouncing mascot and 
//    an animated speech bubble. Optimized for seamless content updates 
//    using transition animations.
//
//  * TODO: 
//    - Support different animation curves based on message priority 
//      (e.g., faster bounce for critical warnings).
//    - Abstract the speech bubble shape into a custom painter for better 
//      control over the 'tail' direction.
// -----------------------------------------------------------------------------

class AnimatedPiggyMessage extends StatefulWidget {
  final String message;
  final String imagePath;

  const AnimatedPiggyMessage({
    super.key,
    required this.message,
    this.imagePath = 'images/pig_happy.png',
  });

  @override
  State<AnimatedPiggyMessage> createState() => _AnimatedPiggyMessageState();
}

class _AnimatedPiggyMessageState extends State<AnimatedPiggyMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pigController;
  late Animation<Offset> _pigAnimation;

  @override
  void initState() {
    super.initState();
    
    // [Animation Engine] Persistent bouncing loop for the mascot.
    _pigController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pigAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.2), 
    ).animate(
      CurvedAnimation(parent: _pigController, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _pigController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isVisible = widget.message.isNotEmpty;

    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isVisible ? 1.0 : 0.0,
        child: isVisible
            ? Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mascot Layer: Implements a playful SlideTransition.
                    SlideTransition(
                      position: _pigAnimation,
                      child: Image.asset(
                        widget.imagePath,
                        width: 60,
                        height: 60,
                      ),
                    ),
                    const SizedBox(width: 4),
                    
                    // Bubble Layer: Handles elegant text switching.
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          // Key is essential for the framework to trigger the cross-fade animation.
                          key: ValueKey<String>(widget.message),
                          margin: const EdgeInsets.only(left: 10, top: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            widget.message,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }
}