import 'package:flutter/material.dart';

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
  
  // [Logic] Determine if the bubble should be visible
  // Even if message is empty, we don't kill the whole widget.
  bool hasMessage = widget.message.isNotEmpty;

  return Padding(
    padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Piggy Mascot Layer (Always Bouncing)
        // This part stays as long as the parent (RadarChartPage) shows this widget.
        SlideTransition(
          position: _pigAnimation,
          child: Image.asset(
            widget.imagePath,
            width: 60,
            height: 60,
          ),
        ),
        const SizedBox(width: 4),

        // 2. Bubble Layer (Independent Animation)
        // It fades and shrinks/expands based on hasMessage.
        Expanded(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: hasMessage ? 1.0 : 0.0, // Fades out when message is empty
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: hasMessage
                  ? Container(
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
                    )
                  : const SizedBox(width: double.infinity, height: 0), // Keeps the pig layout
            ),
          ),
        ),
      ],
    ),
  );
}
}