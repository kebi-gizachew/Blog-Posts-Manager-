/// Domain model representing a blog post from JSONPlaceholder.
class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  final int id;
  final int userId;
  final String title;
  final String body;

  /// Builds a [Post] from JSON returned by the API.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  /// Serializes this post for create/update requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }

  /// Returns a copy with selectively replaced fields (used after edits).
  Post copyWith({
    int? id,
    int? userId,
    String? title,
    String? body,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Post &&
            id == other.id &&
            userId == other.userId &&
            title == other.title &&
            body == other.body;
  }

  @override
  int get hashCode => Object.hash(id, userId, title, body);
}