import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.lato(),
      readOnly: readOnly,
      onTap: onTap,
      enabled: enabled,
      keyboardType: keyboardType,
      cursorColor: Theme.of(context).colorScheme.primary,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
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
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14,
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextStyle? style;
  final TextAlign textAlign;



  CustomText({
    required this.text,
    this.fontSize = 16,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style ??
          GoogleFonts.lato(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
    );
  }
}

class CustomLoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  CustomLoadingIndicator({this.color = Colors.blue, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(
      color: color,
      size: size,
    );
  }
}

class CustomNeumorphicButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Made nullable
  final Color? color;
  final double borderRadius;
  final double elevation;

  CustomNeumorphicButton({
    required this.text,
    this.onPressed, // Updated to accept null
    this.color,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: onPressed, // Now accepts null
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? colorScheme.primaryContainer,
        elevation: elevation,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}