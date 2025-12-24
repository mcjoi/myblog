import 'dart:convert';
import 'dart:io';

String _esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

void main(List<String> args) {
  final baseUrl = args.isNotEmpty ? args[0] : 'https://mcjoi.github.io';

  final indexFile = File('./website/posts/index.json');
  if (!indexFile.existsSync()) {
    stderr.writeln('❌ ./website/posts/index.json not found');
    exit(1);
  }

  final index =
      jsonDecode(indexFile.readAsStringSync()) as Map<String, dynamic>;
  final posts = (index['posts'] as List).cast<Map<String, dynamic>>();

  final urls = <Map<String, String>>[];

  // 메인 페이지
  urls.add({
    'loc': '$baseUrl/',
    'priority': '1.0',
  });

  // 게시글 페이지
  for (final p in posts) {
    final slug = p['slug']?.toString();
    if (slug == null || slug.isEmpty) continue;

    final date = p['date']?.toString();

    urls.add({
      'loc': '$baseUrl/post/$slug',
      if (date != null && date.isNotEmpty) 'lastmod': date,
      'priority': '0.8',
    });
  }

  final outDir = Directory('./website/web');
  outDir.createSync(recursive: true);

  // ===== sitemap.xml =====
  final buf = StringBuffer();
  buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buf.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

  for (final u in urls) {
    buf.writeln('  <url>');
    buf.writeln('    <loc>${_esc(u['loc']!)}</loc>');
    if (u.containsKey('lastmod')) {
      buf.writeln('    <lastmod>${_esc(u['lastmod']!)}</lastmod>');
    }
    buf.writeln('    <priority>${u['priority']}</priority>');
    buf.writeln('  </url>');
  }

  buf.writeln('</urlset>');

  File('./website/web/sitemap.xml').writeAsStringSync(buf.toString());

  // ===== robots.txt =====
  File('./website/web/robots.txt').writeAsStringSync('''
User-agent: *
Allow: /

Sitemap: $baseUrl/sitemap.xml
''');

  stdout.writeln('✅ sitemap.xml & robots.txt generated');
}
