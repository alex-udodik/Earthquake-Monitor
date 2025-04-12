/*import 'package:flutter/material.dart';

class PulsatingMarker extends StatefulWidget {
  final double magnitude;

  const PulsatingMarker({Key? key, required this.magnitude}) : super(key: key);

  @override
  State<PulsatingMarker> createState() => _PulsatingMarkerState();
}

class _PulsatingMarkerState extends State<PulsatingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Set up a unique animation duration based on magnitude
    final animationDuration = Duration(
      milliseconds: (2000 ~/ widget.magnitude).toInt(),
    );

    // Create an independent controller for each marker
    _controller = AnimationController(
      vsync: this,
      duration: animationDuration,
    )..repeat(reverse: true);

    // Set min and max scale based on magnitude
    double minScale = 0.5 + widget.magnitude / 20;
    double maxScale = 2 + widget.magnitude / 10;

    // Apply scaling animation
    _animation = Tween<double>(
      begin: minScale,
      end: maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorFromGradient(double magnitude) {
    double normalizedMagnitude = magnitude.clamp(0.0, 10.0);

    final List<Color> gradientColors = [
      Colors.green, // 0.0 - 2.9
      Colors.lightGreen, // 3.0 - 3.9
      Colors.yellow, // 4.0 - 4.9
      Colors.amber, // 5.0 - 5.9
      Colors.orange, // 6.0 - 6.9
      Colors.deepOrange, // 7.0 - 7.9
      Colors.red, // 8.0 - 8.9
      Colors.red.shade700, // 9.0 - 9.9
      Colors.brown, // 10.0
    ];

    // Determine index based on whole number magnitude tiers
    int index =
        (normalizedMagnitude.floor()).clamp(0, gradientColors.length - 1);

    return gradientColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsating circle
            Container(
              width: _animation.value * 20,
              height: _animation.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorFromGradient(widget.magnitude).withOpacity(0.5),
              ),
            ),
            // Central circle with contrasting background
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.7), // Background for contrast
              ),
              child: Center(
                child: Text(
                  widget.magnitude.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Larger text size
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black, // Text shadow
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
*/

import 'package:flutter/material.dart';

class PulsatingMarker extends StatefulWidget {
  final double magnitude;
  final bool animate; // ✅ Toggle animation

  const PulsatingMarker({
    Key? key,
    required this.magnitude,
    this.animate = true,
  }) : super(key: key);

  @override
  State<PulsatingMarker> createState() => _PulsatingMarkerState();
}

class _PulsatingMarkerState extends State<PulsatingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    if (widget.animate) {
      final animationDuration = Duration(
        milliseconds: (2000 ~/ widget.magnitude).toInt(),
      );

      _controller = AnimationController(
        vsync: this,
        duration: animationDuration,
      )..repeat(reverse: true);

      double minScale = 0.5 + widget.magnitude / 20;
      double maxScale = 2 + widget.magnitude / 10;

      _animation = Tween<double>(
        begin: minScale,
        end: maxScale,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    } else {
      _controller = AnimationController(vsync: this, duration: Duration.zero);
      _animation = AlwaysStoppedAnimation<double>(1.0); // 🔒 No scale
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorFromGradient(double magnitude) {
    double normalizedMagnitude = magnitude.clamp(0.0, 10.0);

    final List<Color> gradientColors = [
      Colors.green, // 0.0 - 2.9
      Colors.lightGreen,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.red,
      Colors.red.shade700,
      Colors.brown, // 10.0
    ];

    int index = normalizedMagnitude.floor().clamp(0, gradientColors.length - 1);
    return gradientColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsating or static circle
            Container(
              width: _animation.value * 20,
              height: _animation.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getColorFromGradient(widget.magnitude).withAlpha(120),
              ),
            ),
            // Central label
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.7),
              ),
              child: Center(
                child: Text(
                  widget.magnitude.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
