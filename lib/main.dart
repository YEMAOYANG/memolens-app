import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/bindings/initial_binding.dart';
import 'app/translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 状态栏透明
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // 初始化 Hive
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');

  // 配置 EasyLoading
  configLoading();

  runApp(const MemoLensApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 12.0
    ..maskColor = Colors.black.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MemoLensApp extends StatelessWidget {
  const MemoLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MemoLens',
      debugShowCheckedModeBanner: false,
      
      // 主题
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      
      // 国际化
      translations: AppTranslations(),
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('en', 'US'),
      
      // 路由
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      // 全局绑定
      initialBinding: InitialBinding(),
      
      // EasyLoading
      builder: EasyLoading.init(),
    );
  }
}
