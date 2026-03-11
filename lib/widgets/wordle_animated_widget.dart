import 'package:Wordle/widgets/animated_letter_card.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class WordleAnimatedWidget extends StatefulWidget {
  const WordleAnimatedWidget({super.key, required this.title});
  final String title;

  @override
  State<WordleAnimatedWidget> createState() => _WordleAnimatedWidgetState();
}

class _WordleAnimatedWidgetState extends State<WordleAnimatedWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = (constraints.maxWidth - 40) / widget.title.length;
        if (size > 60) size = 60;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.title.characters.mapIndexed((index, char) {
            return Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(2),
              child: AnimatedLetterCard(
                char: char,
                cardCount: widget.title.length,
                index: index,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
