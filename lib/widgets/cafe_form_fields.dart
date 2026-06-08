import 'package:flutter/material.dart';

class CafeValidators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? loginIdentity(String? value) {
    final required = requiredField(value, 'your email or phone number');
    if (required != null) return required;

    final text = value!.trim();
    if (text.contains('@')) {
      return email(text);
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? name(String? value, {String fieldName = 'your name'}) {
    final required = requiredField(value, fieldName);
    if (required != null) return required;
    if (value!.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, 'your email');
    if (required != null) return required;
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    final required = requiredField(value, 'your phone number');
    if (required != null) return required;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, 'your password');
    if (required != null) return required;
    if (value!.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

class CafeTextFormField extends StatelessWidget {
  const CafeTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.maxLines = 1,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final int maxLines;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      maxLines: maxLines,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
