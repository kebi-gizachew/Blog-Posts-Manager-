import 'package:flutter/material.dart';

/// Full-screen or inline loading indicator with optional caption.
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message = 'Loading posts…',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      color: Theme.of(context).colorScheme.primary,
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: indicator),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 20),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}