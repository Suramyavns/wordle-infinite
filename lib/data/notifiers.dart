import 'package:flutter/material.dart';

enum LetterState { correct, present, absent, none }

final ValueNotifier isDarkThemeNotifier = ValueNotifier(true);
final ValueNotifier isAuthenticatedNotifier = ValueNotifier(false);
final ValueNotifier<String> currentWordGuessNotifier = ValueNotifier('');
final ValueNotifier<List<String>> wordGuessesNotifier = ValueNotifier([]);
final ValueNotifier<int> currentRowNotifier = ValueNotifier(0);
final ValueNotifier<String?> correctWordNotifier = ValueNotifier(null);

/// One inner list per submitted row, each with 5 [LetterState] values.
final ValueNotifier<List<List<LetterState>>> guessStatesNotifier =
    ValueNotifier([]);

void resetGame() {
  correctWordNotifier.value = null;
  currentWordGuessNotifier.value = '';
  wordGuessesNotifier.value = [];
  currentRowNotifier.value = 0;
  guessStatesNotifier.value = [];
}
