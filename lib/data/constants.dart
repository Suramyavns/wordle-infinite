import 'package:flutter/material.dart';

class WTextStyle extends TextStyle {
  static const tileTextStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const headerTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const keyBoardTextStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const buttonTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );
}

class WKeys {
  static const String isDarkKey = 'isDark';
}

const String firstKeyboardLine = 'qwertyuiop';
const String secondKeyboardLine = 'asdfghjkl';
const String thirdKeyboardLine = 'zxcvbnm';
const List<String> keyboardLines = [
  firstKeyboardLine,
  secondKeyboardLine,
  thirdKeyboardLine,
];
