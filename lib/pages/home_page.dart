import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../types/blog_types.dart';

class HomePage extends StatefulWidget {
  final List<BlogPost> posts;

  const HomePage({
    super.key,
    required this.posts,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int pageSize = 12;
  late int visibleCount;

  @override
  void initState() {
    super.initState();
    visibleCount = pageSize;
  }

  void _loadMore() {
    setState(() {
      visibleCount = (visibleCount + pageSize).clamp(0, widget.posts.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,

      // ===== AppBar =====
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: cs.surface,
        title: const Text('Shaaaallow Dive'),
      ),

      // ===== Body =====
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // ===== Empty State =====
          if (widget.posts.isEmpty) {
            return _EmptyPostsView();
          }

          // ===== Grid column count =====
          int crossAxisCount = 1;
          if (width >= 1280) {
            crossAxisCount = 3;
          } else if (width >= 900) {
            crossAxisCount = 2;
          }

          // ===== Responsive padding =====
          double horizontalPadding = 16;
          if (width >= 1280) {
            horizontalPadding = 220;
          } else if (width >= 900) {
            horizontalPadding = 96;
          } else {
            horizontalPadding = 26;
          }

          final posts = widget.posts.take(visibleCount).toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),

              // ===== Grid =====
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = posts[index];
                      return _ThumbnailCard(post: p);
                    },
                    childCount: posts.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 4 / 3,
                  ),
                ),
              ),

              // ===== More button =====
              if (visibleCount < widget.posts.length)
                SliverPadding(
                  padding: const EdgeInsets.all(32),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: FilledButton.icon(
                        onPressed: _loadMore,
                        icon: const Icon(Icons.expand_more),
                        label: const Text('More'),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 48)),

              // ===== Footer =====
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      color: cs.surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: const Text(
                        '© 2025 Shaaaallow Dive',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =======================================================
// Thumbnail Card
// =======================================================

class _ThumbnailCard extends StatelessWidget {
  final BlogPost post;

  const _ThumbnailCard({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: () => context.go('/post/${post.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Thumbnail =====
            Expanded(
              child: Container(
                width: double.infinity,
                color: cs.surfaceContainerHigh,
                child: post.cover != null
                    ? Image.network(
                        post.cover!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image, size: 40),
              ),
            ),

            // ===== Text =====
            Container(
              width: double.infinity,
              color: cs.surfaceContainer,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.dateIso,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPostsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        const Spacer(),
        Icon(
          Icons.article_outlined,
          size: 56,
          color: cs.onSurface.withAlpha(120),
        ),
        const SizedBox(height: 16),
        Text(
          '아직 게시글이 없습니다.',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          '곧 새로운 글이 올라올 예정입니다.',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: cs.onSurface.withAlpha(120)),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          color: cs.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            '© 2025 Shaaaallow Dive',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
