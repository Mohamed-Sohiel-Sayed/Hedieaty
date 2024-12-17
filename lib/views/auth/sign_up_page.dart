import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
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
                validator: (value) => value != null && value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Sign Up'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/sign-in'), // Navigate to Sign-In
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      String result = await _authController.signUp(email, password);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
      if (result == 'Success') {
        Navigator.pushReplacementNamed(context, '/home'); // Go to Home Page
      }
    }
  }
}
