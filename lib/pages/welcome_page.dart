import 'package:Wordle/data/notifiers.dart';
import 'package:Wordle/utils/theme_service.dart';
import 'package:Wordle/widgets/animated_auth_button.dart';
import 'package:Wordle/widgets/wordle_animated_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: WordleAnimatedWidget(title: 'WORDLE')),
            SizedBox(height: 10.0),
            AnimatedAuthButton(),
          ],
        ),
      ),
    );
  }
}
