class Podcast {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String imageUrl;
  final String author;
  final Duration duration;
  final DateTime publishDate;
  final List<String> tags;
  final int listens;
  final double rating;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.author,
    required this.duration,
    required this.publishDate,
    required this.tags,
    required this.listens,
    required this.rating,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      audioUrl: json['audio_url'],
      imageUrl: json['image_url'],
      author: json['author'],
      duration: Duration(minutes: json['duration_minutes']),
      publishDate: DateTime.parse(json['publish_date']),
      tags: List<String>.from(json['tags']),
      listens: json['listens'],
      rating: json['rating'].toDouble(),
    );
  }
} 