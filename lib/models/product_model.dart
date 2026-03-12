class ProductRating {
  final double rate;
  final int count;

  const ProductRating({
    required this.rate,
    required this.count,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      rate: (json['rate'] as num?)?.toDouble() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'count': count,
    };
  }
}

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final ProductRating rating;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      rating: ProductRating.fromJson(
        (json['rating'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating_rate': rating.rate,
      'rating_count': rating.count,
    };
  }

  factory Product.fromDbMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      rating: ProductRating(
        rate: (map['rating_rate'] as num?)?.toDouble() ?? 0,
        count: (map['rating_count'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}
