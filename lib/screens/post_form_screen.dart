import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_view.dart';
import '../widgets/post_form_fields.dart';

/// Screen for creating a new post or editing an existing one.
class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key, this.post});

  /// When null, the screen operates in create mode.
  final Post? post;

  bool get isEditing => post != null;

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Title is required';
    if (trimmed.length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  String? _validateBody(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Body is required';
    if (trimmed.length < 10) return 'Body must be at least 10 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PostsProvider>();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    String? error;
    if (widget.isEditing) {
      final updated = widget.post!.copyWith(title: title, body: body);
      error = await provider.updatePost(updated);
    } else {
      error = await provider.createPost(title: title, body: body);
    }

    if (!mounted) return;

    if (error != null) {
      SnackbarHelper.showError(context, error);
      return;
    }

    SnackbarHelper.showSuccess(
      context,
      widget.isEditing ? 'Post updated successfully' : 'Post created successfully',
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isMutating = context.watch<PostsProvider>().isMutating;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Post' : 'New Post'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Form(
              key: _formKey,
              child: PostFormFields(
                titleController: _titleController,
                bodyController: _bodyController,
                titleValidator: _validateTitle,
                bodyValidator: _validateBody,
              ),
            ),
          ),
          if (isMutating) const LoadingView(compact: true, message: 'Saving…'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: isMutating ? null : _submit,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(widget.isEditing ? 'Save changes' : 'Publish post'),
            ),
          ),
        ),
      ),
    );
  }
}