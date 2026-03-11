import 'package:Wordle/data/constants.dart';
import 'package:Wordle/data/notifiers.dart';
import 'package:Wordle/data/status_colors.dart';
import 'package:flutter/material.dart';

class WordleKeyboardWidget extends StatefulWidget {
  const WordleKeyboardWidget({super.key});

  @override
  State<WordleKeyboardWidget> createState() => _WordleKeyboardWidgetState();
}

class _WordleKeyboardWidgetState extends State<WordleKeyboardWidget> {
  /// Build a map of letter -> best LetterState from all submitted guesses.
  Map<String, LetterState> _buildLetterStateMap(
    List<String> guesses,
    List<List<LetterState>> allStates,
  ) {
    const statePriority = {
      LetterState.correct: 3,
      LetterState.present: 2,
      LetterState.absent: 1,
      LetterState.none: 0,
    };

    final Map<String, LetterState> map = {};
    for (int r = 0; r < guesses.length && r < allStates.length; r++) {
      final word = guesses[r].toLowerCase();
      final states = allStates[r];
      for (int c = 0; c < word.length && c < states.length; c++) {
        final letter = word[c];
        final newState = states[c];
        final existing = map[letter] ?? LetterState.none;
        if ((statePriority[newState] ?? 0) > (statePriority[existing] ?? 0)) {
          map[letter] = newState;
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      width: double.infinity,
      child: ValueListenableBuilder<List<List<LetterState>>>(
        valueListenable: guessStatesNotifier,
        builder: (context, allStates, _) {
          return ValueListenableBuilder<List<String>>(
            valueListenable: wordGuessesNotifier,
            builder: (context, guesses, _) {
              final letterStateMap = _buildLetterStateMap(guesses, allStates);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(keyboardLines.length, (lineIndex) {
                  final bool isLastRow = lineIndex == keyboardLines.length - 1;
                  return FittedBox(
                    alignment: Alignment.center,
                    child: Row(
                      spacing: 6,
                      children: [
                        ...List.generate(
                          keyboardLines.elementAt(lineIndex).length,
                          (index) {
                            final String currentLine = keyboardLines.elementAt(
                              lineIndex,
                            );
                            final String keyLetter = currentLine.characters
                                .elementAt(index);
                            final LetterState state =
                                letterStateMap[keyLetter] ?? LetterState.none;
                            final Color keyColor = colorForState(state);
                            double boxWidth =
                                MediaQuery.of(context).size.width /
                                firstKeyboardLine.length;

                            return ValueListenableBuilder(
                              valueListenable: currentWordGuessNotifier,
                              builder: (context, guessWord, child) {
                                return GestureDetector(
                                  onTap: () {
                                    currentWordGuessNotifier.value +=
                                        currentLine.characters.elementAt(index);
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                    padding: EdgeInsets.all(6),
                                    width: boxWidth,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: keyColor,
                                    ),
                                    alignment: Alignment.center,
                                    child: Card(
                                      shadowColor: Colors.transparent,
                                      color: Colors.transparent,
                                      child: Text(
                                        keyLetter,
                                        style: WTextStyle.keyBoardTextStyle,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (isLastRow)
                          ValueListenableBuilder(
                            valueListenable: currentWordGuessNotifier,
                            builder: (context, guessWord, child) {
                              final bool canDelete = guessWord.isNotEmpty;
                              double boxWidth =
                                  MediaQuery.of(context).size.width /
                                  firstKeyboardLine.length;
                              return GestureDetector(
                                onTap: canDelete
                                    ? () {
                                        final chars = currentWordGuessNotifier
                                            .value
                                            .characters;
                                        currentWordGuessNotifier.value = chars
                                            .take(chars.length - 1)
                                            .toString();
                                      }
                                    : null,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  padding: EdgeInsets.all(6),
                                  width: boxWidth * 1.4,
                                  height: boxWidth * 1.4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: canDelete
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade800,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.backspace_outlined,
                                    color: canDelete
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }
}
