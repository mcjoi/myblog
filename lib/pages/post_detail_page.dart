import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:markdown/markdown.dart' as md;

import '../types/blog_types.dart';

class PostDetailPage extends StatelessWidget {
  final BlogPost post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  static const double contentMaxWidth = 1080;
  static const double contentPadding = 28;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,

      // ================= AppBar =================
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: cs.surface,
        title: const Text('Shaaaallow Dive'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),

      // ================= Body =================
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // ================= Content =================
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Title =====
                      Text(
                        post.title,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),

                      const SizedBox(height: 8),

                      // ===== Date =====
                      Text(
                        post.dateIso,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: cs.onSurface.withAlpha(180),
                            ),
                      ),

                      const SizedBox(height: 20),

                      Divider(
                        height: 32,
                        thickness: 0.5,
                        color: cs.onSurface.withAlpha(120),
                      ),

                      const SizedBox(height: 24),

                      // ===== Markdown =====
                      _buildMarkdown(context),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ===== Content ↔ Footer spacing =====
          const SliverToBoxAdapter(child: SizedBox(height: 64)),

          // ================= Footer =================
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: cs.surfaceContainerHighest,
                  child: const Text(
                    '© 2025 Shaaaallow Dive',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ Markdown Renderer (공식 확장 포인트만 사용)
  // ============================================================
  Widget _buildMarkdown(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MarkdownBody(
      data: post.markdown,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        blockSpacing: 0,

        // ===== Paragraph =====
        p: TextStyle(
          fontSize: 20,
          height: 1.8,
          color: cs.onSurface,
        ),

        // ===== Headings =====
        h1: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600,
          height: 2.2,
          color: cs.onSurface,
        ),
        h2: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 2.1,
          color: cs.onSurface,
        ),
        h3: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 2.0,
          color: cs.onSurface,
        ),

        // ===== Inline code =====
        code: const TextStyle(
          fontFamily: 'Hack',
          fontSize: 16,
          color: Color(0xFFE6EDF3),
          backgroundColor: Colors.transparent,
        ),

        // ❗ codeblock 스타일은 사용하지 않음 (HighlightView가 전담)
        codeblockDecoration: const BoxDecoration(),
        codeblockPadding: EdgeInsets.zero,

        // ===== Blockquote =====
        blockquote: TextStyle(
          fontSize: 18,
          height: 1.7,
          color: cs.onSurface.withAlpha(180),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: cs.outlineVariant,
              width: 4,
            ),
          ),
        ),

        // ===== Link =====
        a: TextStyle(
          color: cs.secondary,
          decoration: TextDecoration.underline,
        ),
      ),
      builders: {
        'pre': _CodeBlockBuilder(),
        'img': _MarkdownImageBuilder(),
      },
    );
  }
}

// ============================================================
// ✅ GitHub-style Dark Code Block
// ============================================================

class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    String code = element.textContent;
    String? language;

    if (element.children != null && element.children!.isNotEmpty) {
      final child = element.children!.first;
      if (child is md.Element) {
        final classAttr = child.attributes['class'];
        if (classAttr != null && classAttr.startsWith('language-')) {
          language = classAttr.replaceFirst('language-', '');
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 47, 47, 47),
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Transform.translate(
          offset: const Offset(0, 6),
          child: HighlightView(
            code,
            language: language,
            theme: githubDarkTheme, // ⭐ 핵심
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            textStyle: const TextStyle(
              fontFamily: 'NanumGothicCoding',
              letterSpacing: 1.3,
              fontSize: 18,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ✅ Image Builder
// ============================================================

class _MarkdownImageBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final src = element.attributes['src'];
    if (src == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(src, fit: BoxFit.cover),
      ),
    );
  }
}

// ============================================================
// ✅ GitHub Dark Theme (직접 정의)
// ============================================================

const Map<String, TextStyle> githubDarkTheme = {
  'root': TextStyle(
    backgroundColor: Colors.transparent,
    color: Color(0xFFC9D1D9),
  ),
  'keyword': TextStyle(color: Color.fromARGB(255, 255, 253, 114)),
  'built_in': TextStyle(color: Color(0xFFFF7B72)),
  'type': TextStyle(color: Color(0xFF79C0FF)),
  'literal': TextStyle(color: Color(0xFF79C0FF)),
  'number': TextStyle(color: Color(0xFF79C0FF)),
  'string': TextStyle(color: Color(0xFFA5D6FF)),
  'comment': TextStyle(
    color: Color(0xFF8B949E),
    fontStyle: FontStyle.italic,
  ),
  'meta': TextStyle(color: Color(0xFFD2A8FF)),
  'symbol': TextStyle(color: Color(0xFFA5D6FF)),
};
