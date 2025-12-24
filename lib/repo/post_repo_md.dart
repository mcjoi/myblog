import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import '../types/blog_types.dart';

class PostRepoMd {
  /// ✅ posts가 배포된 raw GitHub 경로
  /// 예: https://raw.githubusercontent.com/{user}/{repo}/master
  static const String postsBaseUrl =
      'https://raw.githubusercontent.com/mcjoi/img1-repo/refs/heads/master';

  /// ============================================================
  /// 모든 글 목록 조회
  /// - 실패 시: 빈 리스트 반환 (UI 안전)
  /// ============================================================
  Future<List<BlogPost>> list() async {
    try {
      final indexUrl = Uri.parse('$postsBaseUrl/index.json');
      debugPrint('📄 Fetch index.json: $indexUrl');

      final indexRes = await http.get(indexUrl);
      if (indexRes.statusCode != 200) {
        debugPrint('❌ index.json HTTP ${indexRes.statusCode}');
        return [];
      }

      final indexJson = jsonDecode(indexRes.body) as Map<String, dynamic>;
      final items = (indexJson['posts'] as List).cast<Map<String, dynamic>>();

      if (items.isEmpty) {
        debugPrint('ℹ️ index.json is empty');
        return [];
      }

      final posts = <BlogPost>[];

      for (final item in items) {
        final mdFile = item['md'] as String?;
        if (mdFile == null || mdFile.isEmpty) continue;

        final mdUrl = Uri.parse('$postsBaseUrl/$mdFile');
        debugPrint('📄 Fetch md: $mdUrl');

        final mdRes = await http.get(mdUrl);
        if (mdRes.statusCode != 200) {
          debugPrint('⚠️ md load failed: $mdFile');
          continue;
        }

        posts.add(_parseMd(item, mdRes.body));
      }

      posts.sort((a, b) => b.date.compareTo(a.date));
      debugPrint('✅ Loaded ${posts.length} posts');
      return posts;
    } catch (e, st) {
      debugPrint('🔥 PostRepoMd error: $e');
      debugPrintStack(stackTrace: st);
      return [];
    }
  }

  /// ============================================================
  /// MD + Front-matter 파싱
  /// ============================================================
  BlogPost _parseMd(Map<String, dynamic> indexMeta, String raw) {
    final parts = raw.split('---');
    if (parts.length < 2) {
      throw Exception('Invalid front-matter');
    }

    final meta = loadYaml(parts[1]) as YamlMap;
    final body = parts.length > 2 ? parts.sublist(2).join('---') : '';

    final dateIso = meta['date']?.toString() ?? '1970-01-01';

    return BlogPost(
      slug: meta['slug']?.toString() ?? indexMeta['slug'],
      title: meta['title']?.toString() ?? indexMeta['title'] ?? '(제목 없음)',
      dateIso: dateIso,
      date: DateTime.tryParse(dateIso) ?? DateTime(1970),
      markdown: body.trim(), // ✅ 그대로 전달
      blocks: const [], // ❌ 더 이상 사용하지 않음
      cover: meta['cover']?.toString(),
      excerpt: meta['excerpt']?.toString(),
    );
  }
}
