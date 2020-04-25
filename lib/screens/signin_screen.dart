import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timwan/screens/signup_screen.dart';
import 'package:timwan/viewmodels/signin_view_model.dart';
import 'package:timwan/widgets/loading_button.dart';
import 'package:timwan/widgets/text_link.dart';

class SignInScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SignInViewModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                  controller: emailController,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                  obscureText: true,
                  controller: passwordController,
                ),
                SizedBox(
                  height: 25,
                ),
                LoadingButton(
                  title: "Sign In",
                  isLoading: model.isLoading,
                  onPressed: () => model.signInWithEmail(
                      email: emailController.text,
                      password: passwordController.text),
                ),
                SizedBox(
                  height: 20,
                ),
                TextLink(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignUpScreen()));
                  },
                  text: 'Create an account if you\'re new.',
                ),
                Divider(
                  height: 24,
                ),
                LoadingButton(
                  title: "or Continue Anonymous",
                  isLoading: model.isLoading,
                  onPressed: model.signInAnonymously,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
