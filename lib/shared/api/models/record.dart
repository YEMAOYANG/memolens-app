class Record {
  final String id;
  final String imageUrl;
  final String? ocrText;
  final String? aiSummary;
  final String? contentType;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  const Record({required this.id, required this.imageUrl, this.ocrText, this.aiSummary, this.contentType, this.tags = const [], this.metadata, required this.createdAt});
  factory Record.fromJson(Map<String, dynamic> j) => Record(id: j['id'], imageUrl: j['image_url'], ocrText: j['ocr_text'], aiSummary: j['ai_summary'], contentType: j['content_type'], tags: List<String>.from(j['tags'] ?? []), metadata: j['metadata'], createdAt: DateTime.parse(j['created_at']));
}
class SearchResult {
  final String answer;
  final List<Record> sources;
  const SearchResult({required this.answer, this.sources = const []});
  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(answer: j['answer'], sources: (j['sources'] as List? ?? []).map((e) => Record.fromJson(e)).toList());
}
class AppUser {
  final String id;
  final String? phone;
  final String plan;
  final int monthlyUsed;
  final int quota;
  const AppUser({required this.id, this.phone, this.plan = 'free', this.monthlyUsed = 0, this.quota = 200});
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(id: j['id'], phone: j['phone'], plan: j['plan'] ?? 'free', monthlyUsed: j['monthly_used'] ?? 0, quota: j['quota'] ?? 200);
}
