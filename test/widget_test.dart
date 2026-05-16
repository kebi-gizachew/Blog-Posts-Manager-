import 'package:blog_posts_manager/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App shows Blog Posts Manager title', (tester) async {
    await tester.pumpWidget(const BlogPostsManagerApp());
    await tester.pump();

    expect(find.text('Blog Posts Manager'), findsOneWidget);
  });
}
