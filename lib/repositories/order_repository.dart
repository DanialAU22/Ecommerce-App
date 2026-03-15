import '../database/sqlite_helper.dart';
import '../models/order_model.dart';

class OrderRepository {
  OrderRepository({SQLiteHelper? sqliteHelper})
      : _sqliteHelper = sqliteHelper ?? SQLiteHelper.instance;

  final SQLiteHelper _sqliteHelper;

  Future<void> placeOrder(OrderModel order) {
    return _sqliteHelper.insertOrder(order.toDbMap());
  }

  Future<List<OrderModel>> getOrders() async {
    final List<Map<String, dynamic>> rows = await _sqliteHelper.getOrders();
    return rows.map(OrderModel.fromDbMap).toList();
  }
}
