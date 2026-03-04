class AppUser {
  final String id;
  final String phone;
  final String? nickname;
  final String? avatar;
  final bool isPro;
  final int quota;
  final int monthlyUsed;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.phone,
    this.nickname,
    this.avatar,
    this.isPro = false,
    this.quota = 200,
    this.monthlyUsed = 0,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      phone: json['phone'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      isPro: json['is_pro'] ?? false,
      quota: json['quota'] ?? 200,
      monthlyUsed: json['monthly_used'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  int get remaining => quota - monthlyUsed;
  double get usagePercent => monthlyUsed / quota;
}
