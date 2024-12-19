import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../shared/widgets/custom_widgets.dart';
import '../../utils/validators.dart';
import '../../routes.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController(); // Add mobile controller
  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _mobileController.dispose(); // Dispose mobile controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AuthTextField(
                controller: _nameController,
                labelText: 'Name',
                validator: Validators.validateName,
              ),
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
              AuthTextField(
                controller: _mobileController,
                labelText: 'Mobile', // Add mobile field
                validator: Validators.validateMobile, // Add mobile validator
              ),
              SizedBox(height: 20),
              AuthButton(
                text: 'Sign Up',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _authController.register(
                      _emailController.text,
                      _passwordController.text,
                      _nameController.text,
                      _mobileController.text, // Pass mobile field
                    );
                    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
                  }
                },
              ),
              AuthTextButton(
                text: 'Already have an account? Sign In',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}