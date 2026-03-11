import 'package:Wordle/data/notifiers.dart';
import 'package:Wordle/utils/auth_service.dart';
import 'package:Wordle/utils/firestore_service.dart';
import 'package:Wordle/utils/generator_service.dart';
import 'package:Wordle/widgets/animated_letter_input.dart';
import 'package:Wordle/widgets/game_over_dialog.dart';
import 'package:flutter/material.dart';

class InputFieldsWidget extends StatefulWidget {
  const InputFieldsWidget({super.key});

  @override
  State<InputFieldsWidget> createState() => _InputFieldsWidgetState();
}

class _InputFieldsWidgetState extends State<InputFieldsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  DateTime _gameStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    currentWordGuessNotifier.addListener(_onGuessChanged);
    _gameStartTime = DateTime.now();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    currentWordGuessNotifier.removeListener(_onGuessChanged);
    _shakeController.dispose();
    super.dispose();
  }

  void _showInvalidNotification() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Not in word list',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _onGuessChanged() {

    if (currentWordGuessNotifier.value.length >= 5 &&
        correctWordNotifier.value != null) {
      final submittedWord = currentWordGuessNotifier.value;

      if (!isValidWord(submittedWord)) {
        isValidWordNotifier.value = false;
        _shakeController.forward(from: 0.0);
        _showInvalidNotification();
        return;
      } else {
        isValidWordNotifier.value = true;
      }

      // Evaluate letter states against the correct word
      final correctWord = correctWordNotifier.value!.toLowerCase();
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
      await addStatsToFirestore(userId, tries, isWin);
    }
  }

  void _showGameOverDialog(bool isWin, int tries, double avgSpeed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GameOverDialog(isWin: isWin, tries: tries);
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
                    final isCurrentRow = rowIndex == currentRowNotifier.value;

                    Widget rowContent = Container(
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
                                  borderRadius: BorderRadiusGeometry.circular(4),
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
                    );

                    if (isCurrentRow) {
                      rowContent = AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          );
                        },
                        child: rowContent,
                      );
                    }

                    return FittedBox(
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      child: rowContent,
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
