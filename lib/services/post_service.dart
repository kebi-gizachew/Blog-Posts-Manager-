import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import 'api_exception.dart';

/// Handles all HTTP communication with JSONPlaceholder posts endpoint.
class PostService {
  PostService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _postsPath = '/posts';

  final http.Client _client;

  Uri get _postsUri => Uri.parse('$_baseUrl$_postsPath');

  Uri _postUri(int id) => Uri.parse('$_baseUrl$_postsPath/$id');

  /// Fetches every post from the remote API.
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _client.get(_postsUri);
      return _parseListResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Unable to reach the server. Check your internet connection.',
      );
    }
  }

  /// Creates a new post. JSONPlaceholder echoes the payload with a fake id.
  Future<Post> createPost({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    final payload = {
      'title': title,
      'body': body,
      'userId': userId,
    };

    try {
      final response = await _client.post(
        _postsUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return _parseSingleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Could not create the post. Please try again.',
      );
    }
  }

  /// Replaces an existing post on the server (PUT).
  Future<Post> updatePost(Post post) async {
    try {
      final response = await _client.put(
        _postUri(post.id),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(post.toJson()),
      );
      return _parseSingleResponse(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Could not update the post. Please try again.',
      );
    }
  }

  /// Deletes a post by id. JSONPlaceholder always returns 200 for demo data.
  Future<void> deletePost(int id) async {
    try {
      final response = await _client.delete(_postUri(id));
      if (response.statusCode < 200  response.statusCode >= 300) {
        throw ApiException(
          'Failed to delete post.',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Could not delete the post. Please try again.',
      );
    }
  }

  List<Post> _parseListResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'Server returned an unexpected response.',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw ApiException('Invalid data format received from server.');
    }

    return decoded
        .map((item) => Post.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Post _parseSingleResponse(http.Response response) {
    if (response.statusCode < 200  response.statusCode >= 300) {
      throw ApiException(
        'Server rejected the request.',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Invalid data format received from server.');
    }

    return Post.fromJson(decoded);
  }
}