import 'package:Wordle/data/constants.dart';
import 'package:Wordle/data/notifiers.dart';
import 'package:Wordle/utils/generator_service.dart';
import 'package:Wordle/utils/theme_service.dart';
import 'package:Wordle/widgets/drawer_widget.dart';
import 'package:Wordle/widgets/input_fields.dart';
import 'package:Wordle/widgets/wordle_animated_widget.dart';
import 'package:Wordle/widgets/wordle_keyboard_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    generateWord();
    currentRowNotifier.addListener(_onRowChanged);
  }

  @override
  void dispose() {
    currentRowNotifier.removeListener(_onRowChanged);
    super.dispose();
  }

  void _onRowChanged() {
    if (currentRowNotifier.value == 0) {
      generateWord();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 72,
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.72,
          child: WordleAnimatedWidget(title: 'WORDLE'),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: isDarkThemeNotifier,
            builder: (context, isDarkTheme, child) {
              return IconButton(
                onPressed: () {
                  persistTheme(!isDarkTheme);
                  isDarkThemeNotifier.value = !isDarkTheme;
                },
                icon: isDarkTheme
                    ? Icon(CupertinoIcons.moon)
                    : Icon(CupertinoIcons.sun_max),
              );
            },
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            Text('Guess the word', style: WTextStyle.headerTextStyle),
            InputFieldsWidget(),
            WordleKeyboardWidget(),
          ],
        ),
      ),
    );
  }
}
