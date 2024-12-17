import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter your password' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Sign In'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/sign-up'), // Navigate to Sign-Up
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      String result = await _authController.signIn(email, password);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
      if (result == 'Success') {
        Navigator.pushReplacementNamed(context, '/home'); // Go to Home Page
      }
    }
  }
}
