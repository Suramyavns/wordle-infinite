import 'dart:math';

import 'package:Wordle/data/notifiers.dart';
import 'package:word_generator/word_generator.dart';

final wordGenerator = WordGenerator();

void generateWord() {
  if (correctWordNotifier.value != null) return;
  List<String> words = [
    wordGenerator.nounsByLength(5)[Random().nextInt(
      wordGenerator.nounsByLength(5).length,
    )],
    wordGenerator.verbsByLength(5)[Random().nextInt(
      wordGenerator.verbsByLength(5).length,
    )],
  ];
  final word = words[Random().nextInt(words.length)];
  correctWordNotifier.value = word;
}
