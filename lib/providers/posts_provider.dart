import 'package:flutter/foundation.dart';

import '../models/post.dart';
import '../services/api_exception.dart';
import '../services/post_service.dart';

/// Central state holder for the posts list and async operations.
class PostsProvider extends ChangeNotifier {
  PostsProvider({PostService? postService})
      : _postService = postService ?? PostService();

  final PostService _postService;

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;

  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;
  bool get hasPosts => _posts.isNotEmpty;

  /// Loads posts from the API and updates listeners.
  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _postService.fetchPosts();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading posts.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a post remotely and prepends it to the local list.
  Future<String?> createPost({
    required String title,
    required String body,
  }) async {
    _isMutating = true;
    notifyListeners();

    try {
      final created = await _postService.createPost(
        title: title,
        body: body,
      );
      // JSONPlaceholder may return id 101; keep list consistent for the UI.
      _posts = [created, ..._posts];
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Failed to create the post.';
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  /// Updates a post and swaps it in the cached list.
  Future<String?> updatePost(Post post) async {
    _isMutating = true;
    notifyListeners();

    try {
      final updated = await _postService.updatePost(post);
      final index = _posts.indexWhere((item) => item.id == updated.id);
      if (index != -1) {
        final copy = List<Post>.from(_posts);
        copy[index] = updated;
        _posts = copy;
      }
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Failed to update the post.';
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  /// Removes a post locally after a successful delete call.
  Future<String?> deletePost(int id) async {
    _isMutating = true;
    notifyListeners();

    try {
      await _postService.deletePost(id);
      _posts = _posts.where((post) => post.id != id).toList();
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (_) {
      return 'Failed to delete the post.';
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}