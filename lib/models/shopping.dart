double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

String prettyCategory(String slug) => slug
    .split('-')
    .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

class Shopping {
  final int id;
  final String title;
  final String category;
  final double price;
  final String thumbnail;

  Shopping({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.thumbnail,
  });

  factory Shopping.fromJson(Map<String, dynamic> json) => Shopping(
        id: json['id'] as int,
        title: json['title'] ?? '',
        category: json['category'] ?? '',
        price: _toDouble(json['price']),
        thumbnail: json['thumbnail'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'category': category,
        'price': price,
        'thumbnail': thumbnail,
      };

  factory Shopping.fromMap(Map map) => Shopping(
        id: map['id'] as int,
        title: map['title'] ?? '',
        category: map['category'] ?? '',
        price: _toDouble(map['price']),
        thumbnail: map['thumbnail'] ?? '',
      );
}

class ShoppingDetail {
  final int id;
  final String title;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;

  ShoppingDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.images,
  });

  factory ShoppingDetail.fromJson(Map<String, dynamic> json) => ShoppingDetail(
        id: json['id'] as int,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        category: json['category'] ?? '',
        brand: json['brand'] ?? '-',
        price: _toDouble(json['price']),
        discountPercentage: _toDouble(json['discountPercentage']),
        rating: _toDouble(json['rating']),
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        thumbnail: json['thumbnail'] ?? '',
        images: List<String>.from(json['images'] ?? const []),
      );

  String get mainImage => images.isNotEmpty ? images.first : thumbnail;

  Shopping toShopping() => Shopping(
        id: id,
        title: title,
        category: category,
        price: price,
        thumbnail: thumbnail,
      );
}
