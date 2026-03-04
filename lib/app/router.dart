import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/pages/onboarding_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/camera/pages/camera_page.dart';
import '../features/camera/pages/archive_result_page.dart';
import '../features/search/pages/search_page.dart';
import '../features/gallery/pages/gallery_page.dart';
import '../features/detail/pages/detail_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../shared/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    debugLogDiagnostics: true,
    routes: [
      // 引导页（首次启动）
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      // 登录
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // 主框架（Tab 导航）
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainScaffold(shell: shell),
        branches: [
          // Tab 0：首页
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ]),
          // Tab 1：相机（中间大按钮）
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/camera',
              builder: (context, state) => const CameraPage(),
              routes: [
                GoRoute(
                  path: 'result',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return ArchiveResultPage(
                      imagePath: extra['imagePath'] as String,
                      ocrText: extra['ocrText'] as String,
                    );
                  },
                ),
              ],
            ),
          ]),
          // Tab 2：搜索
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
          ]),
          // Tab 3：相册
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/gallery',
              builder: (context, state) => const GalleryPage(),
            ),
          ]),
          // Tab 4：我的
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ]),
        ],
      ),
      // 详情页（全局路由，可从任意 Tab 跳入）
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) => DetailPage(recordId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      // TODO: 判断是否已登录、是否首次启动
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('页面不存在：${state.error}')),
    ),
  );
});
