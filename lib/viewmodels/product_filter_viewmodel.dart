class ProductFilterViewModel {
  const ProductFilterViewModel({
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.minRating = 0,
    this.category,
    this.sortOption = ProductSortOption.none,
  });

  final double minPrice;
  final double maxPrice;
  final double minRating;
  final String? category;
  final ProductSortOption sortOption;

  ProductFilterViewModel copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? category,
    bool clearCategory = false,
    ProductSortOption? sortOption,
  }) {
    return ProductFilterViewModel(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      category: clearCategory ? null : (category ?? this.category),
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

enum ProductSortOption {
  none,
  priceLowToHigh,
  priceHighToLow,
  rating,
}
