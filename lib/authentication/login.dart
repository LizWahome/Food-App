import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:foodpanda/global/global.dart';
import 'package:foodpanda/mainScreens/home_screen.dart';
import 'package:foodpanda/widgets/error_dialog.dart';
import 'package:foodpanda/widgets/loading_dialog.dart';

import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
              message: "Please fill in the required information",
            );
          });
    }
  }

  loginNow() async {
    showDialog(
        context: context,
        builder: (context) {
          return const LoadingDialog(
            message: "Checking credentials",
          );
        });

    User? currentUser;
    await firebaseAuth
        ?.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim())
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      log('proceeding to read data and set data to locally');
      await readDataAndSetDataLocally(currentUser!).then((value) {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      });
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    log('CURRENT USER: $currentUser');
    final data = await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentUser.uid)
        .get();
    log('OUR DATA: $data');
    // await FirebaseFirestore.instance
    //     .collection("sellers")
    //     .doc(currentUser.uid)
    //     .get()
    //     .then((snapshot) async {
    //   await sharedPreferences!.setString("uid", snapshot.data()!["sellerUid"]);
    //   await sharedPreferences!
    //       .setString("name", snapshot.data()!["sellerName"]);
    //   await sharedPreferences!
    //       .setString("email", snapshot.data()!["sellerEmail"]);
    //   await sharedPreferences!
    //       .setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Image.asset('images/seller.png'),
          ),
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: emailController,
                data: Icons.email,
                hintText: "Email",
                labelText: "Enter your email",
                isObscure: false,
              ),
              CustomTextField(
                controller: passwordController,
                data: Icons.lock,
                hintText: "Password",
                labelText: "Enter your password",
                isObscure: true,
              ),
              ElevatedButton(
                onPressed: () {
                  formValidation();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 10)),
                child: const Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        )
      ]),
    );
  }
}
