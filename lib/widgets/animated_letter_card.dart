import 'package:Wordle/data/constants.dart';
import 'package:flutter/material.dart';

class AnimatedLetterCard extends StatefulWidget {
  const AnimatedLetterCard({
    super.key,
    required this.char,
    required this.cardCount,
    required this.index,
  });

  final int cardCount;
  final int index;
  final String char;

  @override
  State<AnimatedLetterCard> createState() => _AnimatedLetterCardState();
}

class _AnimatedLetterCardState extends State<AnimatedLetterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  Color color = Colors.transparent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    double step = 1.0 / widget.cardCount;

    double start = widget.index * step;
    double end = (widget.index + 1) * step;

    animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.bounceIn),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ScaleTransition(
        scale: animation,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(widget.char, style: WTextStyle.tileTextStyle),
        ),
      ),
    );
  }
}
