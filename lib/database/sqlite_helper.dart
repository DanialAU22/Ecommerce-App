import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteHelper {
  SQLiteHelper._();

  static final SQLiteHelper instance = SQLiteHelper._();

  static const String _databaseName = 'ecommerce_app.db';
  static const int _databaseVersion = 2;

  static const String cartTable = 'cart_items';
  static const String favoriteTable = 'favorites';
  static const String orderTable = 'orders';
  static const String reviewTable = 'reviews';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await _createBaseTables(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await _createOrderTable(db);
          await _createReviewTable(db);
        }
      },
    );
  }

  Future<void> _createBaseTables(Database db) async {
    await db.execute('''
      CREATE TABLE $cartTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        image TEXT NOT NULL,
        rating_rate REAL NOT NULL,
        rating_count INTEGER NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $favoriteTable (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        image TEXT NOT NULL,
        rating_rate REAL NOT NULL,
        rating_count INTEGER NOT NULL
      )
    ''');

    await _createOrderTable(db);
    await _createReviewTable(db);
  }

  Future<void> _createOrderTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $orderTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        products_json TEXT NOT NULL,
        total_price REAL NOT NULL,
        order_date TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createReviewTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $reviewTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        username TEXT NOT NULL,
        review_text TEXT NOT NULL,
        rating REAL NOT NULL,
        review_date TEXT NOT NULL
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return db.query(cartTable, orderBy: 'id DESC');
  }

  Future<void> upsertCartItem(Map<String, dynamic> map) async {
    final db = await database;
    await db.insert(
      cartTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCartItemQuantity(int productId, int quantity) async {
    final db = await database;
    await db.update(
      cartTable,
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> removeCartItem(int productId) async {
    final db = await database;
    await db.delete(
      cartTable,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete(cartTable);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return db.query(favoriteTable, orderBy: 'id DESC');
  }

  Future<void> insertFavorite(Map<String, dynamic> map) async {
    final db = await database;
    await db.insert(
      favoriteTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int productId) async {
    final db = await database;
    await db.delete(
      favoriteTable,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<bool> isFavorite(int productId) async {
    final db = await database;
    final results = await db.query(
      favoriteTable,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  Future<void> insertOrder(Map<String, dynamic> map) async {
    final db = await database;
    await db.insert(orderTable, map);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return db.query(orderTable, orderBy: 'order_date DESC');
  }

  Future<void> insertReview(Map<String, dynamic> map) async {
    final db = await database;
    await db.insert(reviewTable, map);
  }

  Future<List<Map<String, dynamic>>> getReviewsForProduct(int productId) async {
    final db = await database;
    return db.query(
      reviewTable,
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'review_date DESC',
    );
  }
}
