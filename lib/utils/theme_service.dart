import 'package:Wordle/data/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> persistTheme(bool isDarkTheme) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(WKeys.isDarkKey, isDarkTheme);
}
