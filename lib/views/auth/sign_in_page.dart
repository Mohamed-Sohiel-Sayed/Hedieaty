import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../shared/widgets/custom_widgets.dart';
import '../../utils/validators.dart';
import '../../routes.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _emailController,
                labelText: 'Email',
                validator: Validators.validateEmail,
              ),
              AuthTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              SizedBox(height: 20),
              AuthButton(
                text: 'Sign In',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _authController.signIn(
                      _emailController.text,
                      _passwordController.text,
                    );
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                  }
                },
              ),
              AuthTextButton(
                text: 'Don\'t have an account? Sign Up',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.signUp);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}