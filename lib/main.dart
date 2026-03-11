import 'package:Wordle/data/constants.dart';
import 'package:Wordle/data/notifiers.dart';
import 'package:Wordle/firebase_options.dart';
import 'package:Wordle/pages/home_page.dart';
import 'package:Wordle/pages/welcome_page.dart';
import 'package:Wordle/utils/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dicto/dicto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase setup
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  if (kDebugMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Dicto.initialize(localesToInitialize: ['en']);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadThemeMode();
  }

  Future<void> loadThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool(WKeys.isDarkKey) ?? true;
    isDarkThemeNotifier.value = isDark;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkThemeNotifier,
      builder: (context, isDarkTheme, child) {
        return MaterialApp(
          title: 'Wordle',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: isDarkTheme ? Brightness.dark : Brightness.light,
            ),
          ),
          home: SafeArea(
            child: StreamBuilder(
              stream: AuthService().authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  return HomePage();
                }
                return WelcomePage();
              },
            ),
          ),
        );
      },
    );
  }
}
