import 'package:flutter/material.dart';

/// Shows consistent feedback messages across the app.
class SnackbarHelper {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, backgroundColor: const Color(0xFF2E7D4F));
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, backgroundColor: const Color(0xFFC62828));
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
  }
}