class Tweet {
  final int id;
  final String tweet;

  Tweet({
    required this.id,
    required this.tweet,
  });

  /// Convierte JSON a objeto Tweet
  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      id: json['id'] ?? '',
      tweet: json['tweet'] ?? '',
    );
  }

  /// Convierte objeto Tweet a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tweet': tweet,
    };
  }

  @override
  String toString() => 'Tweet(id: $id, tweet: $tweet)';
}
