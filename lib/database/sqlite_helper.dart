import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteHelper {
  SQLiteHelper._();

  static final SQLiteHelper instance = SQLiteHelper._();

  static const String _databaseName = 'ecommerce_app.db';
  static const int _databaseVersion = 1;

  static const String cartTable = 'cart_items';
  static const String favoriteTable = 'favorites';

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
      },
    );
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
}
