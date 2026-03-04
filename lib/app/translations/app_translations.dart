import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'zh_CN': {
      // 通用
      'app_name': 'MemoLens',
      'cancel': '取消',
      'confirm': '确定',
      'save': '保存',
      'delete': '删除',
      'loading': '加载中...',
      'error': '出错了',
      'retry': '重试',
      'success': '成功',
      
      // 首页
      'home.title': '我的记忆',
      'home.empty': '还没有任何记录\n点击下方按钮开始扫描',
      'home.search_hint': '搜索记忆...',
      
      // 相机
      'camera.title': '扫描',
      'camera.scanning': '正在识别...',
      'camera.flash_on': '闪光灯开',
      'camera.flash_off': '闪光灯关',
      
      // 归档结果
      'archive.title': '归档结果',
      'archive.analyzing': 'AI 正在分析...',
      'archive.success': '归档成功！',
      'archive.tags': '标签',
      'archive.add_tag': '添加标签',
      'archive.summary': 'AI 摘要',
      
      // 搜索
      'search.title': '智能搜索',
      'search.hint': '问我任何问题...',
      'search.examples': '试试问：\n「上周拍的名片是谁的？」\n「那张菜单上有什么招牌菜？」',
      
      // 相册
      'gallery.title': '全部记录',
      'gallery.grid': '网格',
      'gallery.list': '列表',
      'gallery.timeline': '时间线',
      'gallery.select_all': '全选',
      'gallery.delete_selected': '删除所选',
      
      // 详情
      'detail.ocr_text': 'OCR 识别文字',
      'detail.copy': '复制',
      'detail.copied': '已复制',
      
      // 设置
      'settings.title': '设置',
      'settings.account': '账户',
      'settings.quota': '本月额度',
      'settings.upgrade': '升级 Pro',
      'settings.theme': '深色模式',
      'settings.language': '语言',
      'settings.notification': '通知',
      'settings.privacy': '隐私政策',
      'settings.terms': '使用条款',
      'settings.about': '关于',
      'settings.logout': '退出登录',
      'settings.version': '版本',
      
      // 登录
      'login.title': '登录 MemoLens',
      'login.phone': '手机号',
      'login.code': '验证码',
      'login.send_code': '发送验证码',
      'login.resend': '重新发送',
      'login.login': '登录',
      'login.agreement': '登录即表示同意',
      'login.terms': '使用条款',
      'login.and': '和',
      'login.privacy': '隐私政策',
      
      // Onboarding
      'onboarding.skip': '跳过',
      'onboarding.next': '下一步',
      'onboarding.start': '开始使用',
      'onboarding.title1': '拍一下，记住一切',
      'onboarding.desc1': '用摄像头扫描名片、白板、文档，AI 自动识别归档',
      'onboarding.title2': '自然语言检索',
      'onboarding.desc2': '直接问「上周那张名片是谁的？」AI 秒级回答',
      'onboarding.title3': '隐私优先设计',
      'onboarding.desc3': 'OCR 在本地处理，数据主权完全属于你',
    },
    'en_US': {
      'app_name': 'MemoLens',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'success': 'Success',
      
      'home.title': 'My Memories',
      'home.empty': 'No records yet\nTap below to start scanning',
      'home.search_hint': 'Search memories...',
      
      'camera.title': 'Scan',
      'camera.scanning': 'Recognizing...',
      'camera.flash_on': 'Flash On',
      'camera.flash_off': 'Flash Off',
      
      'archive.title': 'Archive Result',
      'archive.analyzing': 'AI is analyzing...',
      'archive.success': 'Archived!',
      'archive.tags': 'Tags',
      'archive.add_tag': 'Add tag',
      'archive.summary': 'AI Summary',
      
      'search.title': 'Smart Search',
      'search.hint': 'Ask me anything...',
      'search.examples': 'Try asking:\n"Whose business card was that?"\n"What\'s on that menu?"',
      
      'gallery.title': 'All Records',
      'gallery.grid': 'Grid',
      'gallery.list': 'List',
      'gallery.timeline': 'Timeline',
      'gallery.select_all': 'Select All',
      'gallery.delete_selected': 'Delete Selected',
      
      'detail.ocr_text': 'OCR Text',
      'detail.copy': 'Copy',
      'detail.copied': 'Copied',
      
      'settings.title': 'Settings',
      'settings.account': 'Account',
      'settings.quota': 'Monthly Quota',
      'settings.upgrade': 'Upgrade to Pro',
      'settings.theme': 'Dark Mode',
      'settings.language': 'Language',
      'settings.notification': 'Notifications',
      'settings.privacy': 'Privacy Policy',
      'settings.terms': 'Terms of Service',
      'settings.about': 'About',
      'settings.logout': 'Log Out',
      'settings.version': 'Version',
      
      'login.title': 'Log in to MemoLens',
      'login.phone': 'Phone Number',
      'login.code': 'Verification Code',
      'login.send_code': 'Send Code',
      'login.resend': 'Resend',
      'login.login': 'Log In',
      'login.agreement': 'By logging in, you agree to our',
      'login.terms': 'Terms',
      'login.and': 'and',
      'login.privacy': 'Privacy Policy',
      
      'onboarding.skip': 'Skip',
      'onboarding.next': 'Next',
      'onboarding.start': 'Get Started',
      'onboarding.title1': 'Snap It, Remember It',
      'onboarding.desc1': 'Scan business cards, whiteboards, documents with your camera',
      'onboarding.title2': 'Natural Language Search',
      'onboarding.desc2': 'Ask "Whose business card was that?" AI answers instantly',
      'onboarding.title3': 'Privacy First',
      'onboarding.desc3': 'OCR runs locally. Your data stays yours.',
    },
  };
}
