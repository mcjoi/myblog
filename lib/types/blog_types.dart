enum BlockType { h2, h3, p, image }

class Block {
  final BlockType type;
  final String text;

  const Block({
    required this.type,
    required this.text,
  });
}

class BlogPost {
  final String slug;
  final String title;

  /// yyyy-MM-dd (front-matter 그대로)
  final String dateIso;

  /// DateTime (정렬/비교용)
  final DateTime date;

  /// MD 원문 (--- 아래 전체)
  final String markdown;

  /// 파싱된 블록 (렌더링용)
  final List<Block> blocks;

  final String? cover;
  final String? excerpt;

  const BlogPost({
    required this.slug,
    required this.title,
    required this.dateIso,
    required this.date,
    required this.markdown,
    required this.blocks,
    this.cover,
    this.excerpt,
  });
}
