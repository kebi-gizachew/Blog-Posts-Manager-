import 'package:flutter/material.dart';

/// Reusable title and body fields for create/edit screens.
class PostFormFields extends StatelessWidget {
  const PostFormFields({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.titleValidator,
    required this.bodyValidator,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String? Function(String?) titleValidator;
  final String? Function(String?) bodyValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            hintText: 'Give your post a clear headline',
            prefixIcon: Icon(Icons.title_rounded),
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: titleValidator,
          maxLength: 120,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: bodyController,
          decoration: const InputDecoration(
            labelText: 'Body',
            hintText: 'Write the main content here',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.notes_rounded),
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: bodyValidator,
          maxLines: 8,
          minLines: 5,
          maxLength: 2000,
        ),
      ],
    );
  }
}