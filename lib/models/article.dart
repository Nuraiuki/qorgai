class Article {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String author;
  final DateTime publishDate;
  final List<String> tags;
  final int views;
  final int likes;
  final int comments;
  final String category;
  final bool isFeatured;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.publishDate,
    required this.tags,
    required this.views,
    required this.likes,
    required this.comments,
    required this.category,
    required this.isFeatured,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      author: json['author'],
      publishDate: DateTime.parse(json['publish_date']),
      tags: List<String>.from(json['tags']),
      views: json['views'],
      likes: json['likes'],
      comments: json['comments'],
      category: json['category'],
      isFeatured: json['is_featured'],
    );
  }
} 