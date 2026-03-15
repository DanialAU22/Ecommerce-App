import 'package:flutter/foundation.dart';

import '../database/sqlite_helper.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final Map<int, List<ReviewModel>> _byProduct = <int, List<ReviewModel>>{};

  List<ReviewModel> reviewsFor(int productId) =>
      _byProduct[productId] ?? <ReviewModel>[];

  Future<void> loadReviews(int productId) async {
    final List<Map<String, dynamic>> rows =
        await SQLiteHelper.instance.getReviewsForProduct(productId);

    _byProduct[productId] = rows.map(ReviewModel.fromDbMap).toList();
    notifyListeners();
  }

  Future<void> addReview(ReviewModel review) async {
    await SQLiteHelper.instance.insertReview(review.toDbMap());
    await loadReviews(review.productId);
  }
}
