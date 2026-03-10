import 'package:Wordle/data/constants.dart';
import 'package:Wordle/data/notifiers.dart';
import 'package:flutter/material.dart';

class AnimatedLetterInput extends StatefulWidget {
  const AnimatedLetterInput({
    super.key,
    required this.colIndex,
    required this.word,
    required this.rowIndex,
  });

  final int colIndex;
  final int rowIndex;
  final String word;

  @override
  State<AnimatedLetterInput> createState() => _AnimatedLetterInputState();
}

class _AnimatedLetterInputState extends State<AnimatedLetterInput> {
  Color _colorForState(LetterState state) {
    switch (state) {
      case LetterState.correct:
        return Colors.green.shade600;
      case LetterState.present:
        return Colors.amber.shade600;
      case LetterState.absent:
        return Colors.grey.shade700;
      case LetterState.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.word.characters;
    final String char = widget.colIndex < chars.length
        ? chars.elementAt(widget.colIndex)
        : '';

    return ValueListenableBuilder<List<List<LetterState>>>(
      valueListenable: guessStatesNotifier,
      builder: (context, allStates, _) {
        // Determine the state for this specific cell
        LetterState state = LetterState.none;
        if (widget.rowIndex < allStates.length &&
            widget.colIndex < allStates[widget.rowIndex].length) {
          state = allStates[widget.rowIndex][widget.colIndex];
        }

        final Color tileColor = _colorForState(state);

        return AnimatedContainer(
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: Text(
            char.toUpperCase(),
            style: WTextStyle.buttonTextStyle.copyWith(
              color: state == LetterState.none ? null : Colors.white,
            ),
          ),
        );
      },
    );
  }
}
