import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;
  final TextInputType keyboardType;

  AuthTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.lato(),
      ),
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.lato(),
      readOnly: readOnly,
      onTap: onTap,
      enabled: enabled,
      keyboardType: keyboardType,
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  AuthButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class AuthTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  AuthTextButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.lato(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? style;

  CustomText({required this.text, this.fontSize = 16, this.fontWeight = FontWeight.normal, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? GoogleFonts.lato(fontSize: fontSize, fontWeight: fontWeight),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  CustomLoadingIndicator({this.color = Colors.blue, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return SpinKitCircle(
      color: color,
      size: size,
    );
  }
}

class CustomNeumorphicButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomNeumorphicButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: onPressed,
      style: NeumorphicStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}