import 'package:Wordle/data/notifiers.dart';
import 'package:Wordle/utils/auth_service.dart';
import 'package:Wordle/widgets/animated_letter_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InputFieldsWidget extends StatefulWidget {
  const InputFieldsWidget({super.key});

  @override
  State<InputFieldsWidget> createState() => _InputFieldsWidgetState();
}

class _InputFieldsWidgetState extends State<InputFieldsWidget> {
  DateTime _gameStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentWordGuessNotifier.addListener(_onGuessChanged);
    _gameStartTime = DateTime.now();
  }

  @override
  void dispose() {
    currentWordGuessNotifier.removeListener(_onGuessChanged);
    super.dispose();
  }

  void _onGuessChanged() {
    if (currentWordGuessNotifier.value.length >= 5) {
      final submittedWord = currentWordGuessNotifier.value;

      // Evaluate letter states against the correct word
      final correctWord = correctWordNotifier.value.toLowerCase();
      final guess = submittedWord.toLowerCase();
      final states = List<LetterState>.filled(5, LetterState.absent);

      // Track remaining letters in correct word for yellow matching
      final remainingCorrect = correctWord.characters.toList();

      // First pass: mark greens
      for (int i = 0; i < 5; i++) {
        if (i < guess.length && guess[i] == correctWord[i]) {
          states[i] = LetterState.correct;
          remainingCorrect[i] = ''; // consume this letter
        }
      }

      // Second pass: mark yellows
      for (int i = 0; i < 5; i++) {
        if (states[i] == LetterState.correct) continue;
        if (i < guess.length) {
          final idx = remainingCorrect.indexOf(guess[i]);
          if (idx != -1) {
            states[i] = LetterState.present;
            remainingCorrect[idx] = ''; // consume
          }
        }
      }

      // Store states for this row
      guessStatesNotifier.value = [...guessStatesNotifier.value, states];

      // Add to guess history
      wordGuessesNotifier.value = [...wordGuessesNotifier.value, submittedWord];
      // Advance to the next row
      currentRowNotifier.value = currentRowNotifier.value + 1;
      // Clear the current guess
      currentWordGuessNotifier.value = '';

      // Check for win/loss
      if (guess == correctWord) {
        _handleGameOver(true);
      } else if (currentRowNotifier.value >= 6) {
        _handleGameOver(false);
      }
    }
  }

  Future<void> _handleGameOver(bool isWin) async {
    final tries = wordGuessesNotifier.value.length;
    final endTime = DateTime.now();
    final duration = endTime.difference(_gameStartTime);
    final avgSpeedSeconds = duration.inSeconds / tries;

    if (mounted) {
      _showGameOverDialog(isWin, tries, avgSpeedSeconds);
    }

    final userId = AuthService().currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('stats').add({
        'userId': userId,
        'tries': tries,
        'wasGuessed': isWin,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showGameOverDialog(bool isWin, int tries, double avgSpeed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isWin ? 'Congratulations!' : 'Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWin) ...[
                Text('You guessed the word in $tries tries.'),
              ] else ...[
                Text('Better luck next time!'),
                SizedBox(height: 8),
                Text('The correct word was: ${correctWordNotifier.value}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
                // Optionally trigger word generation in HomePage if needed,
                // but HomePage build will rebuild based on currentRowNotifier change.
                // However, we need a new word.
                // I will add a way to trigger new word generation in HomePage.
              },
              child: Text('Replay'),
            ),
          ],
        );
      },
    );
  }

  String _wordForRow(int rowIndex) {
    final currentRow = currentRowNotifier.value;
    if (rowIndex == currentRow) {
      // Active row: show what the user is currently typing
      return currentWordGuessNotifier.value;
    } else if (rowIndex < currentRow &&
        rowIndex < wordGuessesNotifier.value.length) {
      // Past row: show the submitted guess for that row
      return wordGuessesNotifier.value[rowIndex];
    }
    // Future row: nothing typed yet
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentWordGuessNotifier,
      builder: (context, _, __) {
        return ValueListenableBuilder(
          valueListenable: currentRowNotifier,
          builder: (context, _, __) {
            return Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: List.generate(6, (rowIndex) {
                    final word = _wordForRow(rowIndex);
                    return FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        height: 64,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (colIndex) {
                            return AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                margin: EdgeInsets.all(4),
                                child: Card(
                                  shape: BeveledRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      4,
                                    ),
                                  ),
                                  child: Center(
                                    child: AnimatedLetterInput(
                                      colIndex: colIndex,
                                      rowIndex: rowIndex,
                                      word: word,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
