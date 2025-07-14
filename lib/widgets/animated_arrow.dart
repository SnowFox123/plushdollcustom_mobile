import 'package:flutter/material.dart';

class AnimatedArrow extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const AnimatedArrow({
    super.key,
    this.size = 24,
    this.color = Colors.blue,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _offsetAnim = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_offsetAnim.value, 0),
          child: Icon(
            Icons.arrow_forward,
            color: widget.color,
            size: widget.size,
          ),
        );
      },
    );
  }
}
