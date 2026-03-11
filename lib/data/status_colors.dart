import 'package:Wordle/data/notifiers.dart';
import 'package:flutter/material.dart';

Color colorForState(LetterState state, bool isKeyboard) {
  switch (state) {
    case LetterState.correct:
      return Colors.green.shade600;
    case LetterState.present:
      return Colors.amber.shade600;
    case LetterState.absent:
      return Colors.grey.shade700;
    case LetterState.none:
      return isKeyboard ? Colors.grey : Colors.transparent;
  }
}
