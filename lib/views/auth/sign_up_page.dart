import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/auth_widgets.dart';

class SignUpPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Text(
                "Join Hedieaty",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Create an account to get started",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 32),
              AuthTextField(
                controller: _nameController,
                label: 'Name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              SizedBox(height: 16),
              AuthTextField(
                controller: _phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              AuthButton(
                label: 'Sign Up',
                onPressed: () async {
                  final user = await _authController.signUp(
                    _nameController.text,
                    _emailController.text,
                    _passwordController.text,
                    _phoneController.text,
                  );
                  if (user != null) {
                    Navigator.pushNamed(context, '/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign-up failed')),
                    );
                  }
                },
              ),
              SizedBox(height: 16),
              AuthLink(
                text: "Already have an account?",
                linkText: "Sign In",
                onTap: () {
                  Navigator.pushNamed(context, '/sign-in');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
