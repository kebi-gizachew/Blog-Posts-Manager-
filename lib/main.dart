import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/posts_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const BlogPostsManagerApp());
}

/// Root widget: wires Provider and application theme.
class BlogPostsManagerApp extends StatelessWidget {
  const BlogPostsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostsProvider(),
      child: MaterialApp(
        title: 'Blog Posts Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeScreen(),
      ),
    );
  }
}
