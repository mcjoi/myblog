import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'router.dart';
import 'repo/post_repo_md.dart';
import 'types/blog_types.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

/// =======================================================
/// App Root
/// =======================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme,
      home: const BootStrapPage(),
    );
  }
}

/// =======================================================
/// Bootstrap Page
/// - AppBar / Footer ❌
/// - Router + 로딩만 담당
/// =======================================================
class BootStrapPage extends StatefulWidget {
  const BootStrapPage({super.key});

  @override
  State<BootStrapPage> createState() => _BootStrapPageState();
}

class _BootStrapPageState extends State<BootStrapPage> {
  late final Future<List<BlogPost>> _future;

  @override
  void initState() {
    super.initState();
    _future = PostRepoMd().list();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BlogPost>>(
      future: _future,
      builder: (context, snap) {
        // ⏳ 로딩 중
        if (snap.connectionState == ConnectionState.waiting) {
          return const _GlobalLoading();
        }

        // ❌ 에러
        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Failed to load posts',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        // ✅ 정상 로딩
        final posts = snap.data ?? [];
        final router = buildRouter(posts);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: _theme,
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}

/// =======================================================
/// Global Loading (앱 최초 1회만)
/// =======================================================
class _GlobalLoading extends StatelessWidget {
  const _GlobalLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 24, 24, 24),
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// =======================================================
/// Theme
/// =======================================================
final ThemeData _theme = ThemeData(
  useMaterial3: true,
  fontFamily: 'NotoSansKR',
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromARGB(255, 255, 255, 255),
    onPrimary: Colors.black,
    surface: Color.fromARGB(255, 24, 24, 24),
    onSurface: Colors.white,
    surfaceContainer: Color.fromARGB(255, 18, 18, 18),
    surfaceContainerHigh: Color.fromARGB(255, 31, 31, 31),
    surfaceContainerHighest: Color.fromARGB(255, 18, 18, 18),
    outline: Color(0xFF3A3F5C),
    outlineVariant: Color(0xFF2A2E44),
    secondary: Color(0xFF8A91B5),
    onSecondary: Colors.black,
    error: Colors.redAccent,
    onError: Colors.black,
  ),
);
