import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/post_detail_page.dart';
import 'types/blog_types.dart';

GoRouter buildRouter(List<BlogPost> posts) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return HomePage(posts: posts); // ✅ 수정 포인트
        },
      ),
      GoRoute(
        path: '/post/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          final post = posts.firstWhere(
            (p) => p.slug == slug,
            orElse: () => throw Exception('Post not found'),
          );
          return PostDetailPage(post: post);
        },
      ),
    ],
  );
}
