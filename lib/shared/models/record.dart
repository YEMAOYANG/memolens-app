class Record {
  final String id;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? ocrText;
  final String? summary;
  final String contentType; // whiteboard, business_card, document, receipt, menu, other
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Record({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.ocrText,
    this.summary,
    required this.contentType,
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'],
      userId: json['user_id'],
      imageUrl: json['image_url'],
      thumbnailUrl: json['thumbnail_url'],
      ocrText: json['ocr_text'],
      summary: json['summary'],
      contentType: json['content_type'] ?? 'other',
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'image_url': imageUrl,
    'thumbnail_url': thumbnailUrl,
    'ocr_text': ocrText,
    'summary': summary,
    'content_type': contentType,
    'tags': tags,
    'metadata': metadata,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // 内容类型中文名
  String get contentTypeName {
    switch (contentType) {
      case 'whiteboard': return '白板';
      case 'business_card': return '名片';
      case 'document': return '文档';
      case 'receipt': return '票据';
      case 'menu': return '菜单';
      default: return '其他';
    }
  }
}
