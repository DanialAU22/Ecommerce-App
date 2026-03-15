class ReviewModel {
  const ReviewModel({
    this.id,
    required this.productId,
    required this.username,
    required this.text,
    required this.rating,
    required this.date,
  });

  final int? id;
  final int productId;
  final String username;
  final String text;
  final double rating;
  final DateTime date;

  Map<String, dynamic> toDbMap() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'username': username,
      'review_text': text,
      'rating': rating,
      'review_date': date.toIso8601String(),
    };
  }

  factory ReviewModel.fromDbMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: (map['id'] as num?)?.toInt(),
      productId: (map['product_id'] as num?)?.toInt() ?? 0,
      username: map['username']?.toString() ?? 'Anonymous',
      text: map['review_text']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(map['review_date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
