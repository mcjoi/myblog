import 'dart:convert';
import 'dart:io';

void main() async {
  final postsDir = Directory('website/posts');
  final outFile = File('website/posts/index.json');

  final posts = <Map<String, dynamic>>[];

  for (final file in postsDir.listSync()) {
    if (file is! File) continue;
    if (!file.path.endsWith('.md')) continue;

    final slug = file.uri.pathSegments.last.replaceAll('.md', '');
    final content = await file.readAsString();

    final fm = _parseFrontMatter(content);
    if (fm == null) continue;

    posts.add({
      'slug': slug,
      'title': fm['title'] ?? '(제목 없음)',
      'date': fm['date'] ?? '1970-01-01',
      'excerpt': fm['excerpt'],
      'cover': fm['cover'],
      'md': '$slug.md',
    });
  }

  // 날짜 기준 내림차순
  posts.sort((a, b) => b['date'].compareTo(a['date']));

  final json = const JsonEncoder.withIndent('  ').convert({
    'posts': posts,
  });

  await outFile.writeAsString(json);
  print('✅ index.json generated (${posts.length} posts)');
}

Map<String, String>? _parseFrontMatter(String md) {
  if (!md.startsWith('---')) return null;

  final end = md.indexOf('---', 3);
  if (end == -1) return null;

  final block = md.substring(3, end).trim();
  final map = <String, String>{};

  for (final line in block.split('\n')) {
    final idx = line.indexOf(':');
    if (idx == -1) continue;
    final key = line.substring(0, idx).trim();
    final value = line.substring(idx + 1).trim();
    map[key] = value;
  }
  return map;
}
