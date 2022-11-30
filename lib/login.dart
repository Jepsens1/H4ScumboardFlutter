import 'package:flutter/material.dart';
import 'package:my_app/main.dart';
import 'package:my_app/screens/LoginManager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginManager manager;
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    manager = LoginManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter valid username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username cant be empty";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password cant be empty";
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (await manager.Login(
                      usernameController.text, passwordController.text)) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyHomePage()));
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => _buildPopUp(
                          context,
                          "Login failed",
                          "Either password or username is incorrect"),
                    );
                  }
                }
              },
            ),
            ElevatedButton(
              child: const Text('Register'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (await manager.Register(
                      usernameController.text, passwordController.text)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => _buildPopUp(
                          context,
                          "Register success",
                          "You have now registered, you can now login"),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => _buildPopUp(context,
                          "Register failed", "An error occurered, try again"),
                    );
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildPopUp(
    BuildContext context, String alertTitle, String alertDescription) {
  return AlertDialog(
    title: Text(alertTitle),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(alertDescription),
      ],
    ),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}
