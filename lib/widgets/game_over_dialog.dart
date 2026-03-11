import 'package:Wordle/data/notifiers.dart';
import 'package:flutter/material.dart';

class GameOverDialog extends StatefulWidget {
  const GameOverDialog({super.key, required this.isWin, required this.tries});

  final bool isWin;
  final int tries;

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isWin ? 'Congratulations!' : 'Game Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isWin) ...[
            Text('You guessed the word in ${widget.tries} tries.'),
          ] else ...[
            Text('Better luck next time!'),
            SizedBox(height: 8),
            Text('The correct word was: ${correctWordNotifier.value}'),
          ],
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(maximumSize: Size.infinite),
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
  }
}
