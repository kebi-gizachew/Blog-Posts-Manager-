import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/posts_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/empty_posts_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/post_card.dart';
import 'post_form_screen.dart';

/// Main screen: lists all posts and exposes create/edit/delete flows.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off the initial fetch once the widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostsProvider>().loadPosts();
    });
  }

  Future<void> _openCreateScreen() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PostFormScreen()),
    );
    if (created == true && mounted) {
      // Success snackbar is shown on the form screen; list already updated.
    }
  }

  Future<void> _openEditScreen(Post post) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PostFormScreen(post: post)),
    );
  }

  Future<void> _confirmDelete(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text(
          '“${post.title}” will be removed. This cannot be undone on the demo API.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final error = await context.read<PostsProvider>().deletePost(post.id);
    if (!mounted) return;

    if (error != null) {
      SnackbarHelper.showError(context, error);
    } else {
      SnackbarHelper.showSuccess(context, 'Post deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Posts Manager'),
        actions: [
          IconButton(
            onPressed: () => context.read<PostsProvider>().loadPosts(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<PostsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasPosts) {
            return const LoadingView();
          }

          if (provider.errorMessage != null && !provider.hasPosts) {
            return ErrorView(
              message: provider.errorMessage!,
              onRetry: provider.loadPosts,
            );
          }

          if (!provider.hasPosts) {
            return const EmptyPostsView();
          }
          return RefreshIndicator(
            onRefresh: provider.loadPosts,
            child: Stack(
              children: [
                ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: provider.posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final post = provider.posts[index];
                    return PostCard(
                      post: post,
                      isBusy: provider.isMutating,
                      onEdit: () => _openEditScreen(post),
                      onDelete: () => _confirmDelete(post),
                    );
                  },
                ),
                if (provider.isLoading)
                  const Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateScreen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New post'),
      ),
    );
  }
}