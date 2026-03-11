import 'package:Wordle/data/constants.dart';
import 'package:Wordle/pages/home_page.dart';
import 'package:Wordle/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AnimatedAuthButton extends StatefulWidget {
  const AnimatedAuthButton({super.key});

  @override
  State<AnimatedAuthButton> createState() => _AnimatedAuthButtonState();
}

class _AnimatedAuthButtonState extends State<AnimatedAuthButton>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    Future.delayed(Duration(milliseconds: 2000), () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  Future<void> handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      final userCredential = await AuthService().signInWithGoogle();
      if (userCredential != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        });
      }
    } on GoogleSignInException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${e.description}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth - 48;

        return ScaleTransition(
          scale: animation,
          child: FilledButton(
            onPressed: isLoading
                ? null
                : () async {
                    await handleGoogleSignIn();
                  },
            style: FilledButton.styleFrom(
              minimumSize: Size(width, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? CircularProgressIndicator()
                : Text(
                    'Continue with Google',
                    style: WTextStyle.buttonTextStyle,
                  ),
          ),
        );
      },
    );
  }
}
