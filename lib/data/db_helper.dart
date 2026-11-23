import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class RunRecord {
  final int id;
  final int score;
  final int distance;
  final int candies;
  final DateTime playedAt;

  RunRecord({
    required this.id,
    required this.score,
    required this.distance,
    required this.candies,
    required this.playedAt,
  });
}

class StatsSummary {
  final int runs;
  final int bestDistance;
  final int bestScore;
  final int totalDistance;
  final int totalCandies;
  final int balance; // ขนมที่ใช้ซื้อสกินได้
  final List<RunRecord> recent;

  StatsSummary({
    required this.runs,
    required this.bestDistance,
    required this.bestScore,
    required this.totalDistance,
    required this.totalCandies,
    required this.balance,
    required this.recent,
  });
}

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static const int _version = 2;
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return openDatabase(
        'spooky_gravity_run.db',
        version: _version,
        onCreate: _create,
        onUpgrade: _upgrade,
      );
    }
    final path = p.join(await getDatabasesPath(), 'spooky_gravity_run.db');
    return openDatabase(
      path,
      version: _version,
      onCreate: _create,
      onUpgrade: _upgrade,
    );
  }

  Future<void> _create(Database d, int version) async {
    await d.execute('''
      CREATE TABLE play_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        distance INTEGER NOT NULL,
        candies INTEGER NOT NULL,
        played_at TEXT NOT NULL
      )
    ''');
    await d.execute('''
      CREATE TABLE profile (
        key TEXT PRIMARY KEY,
        value INTEGER NOT NULL
      )
    ''');
    await _createSkinTable(d);
  }

  Future<void> _upgrade(Database d, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createSkinTable(d);
  }

  Future<void> _createSkinTable(Database d) async {
    await d.execute('''
      CREATE TABLE IF NOT EXISTS owned_skins (
        id TEXT PRIMARY KEY,
        selected INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ---------------- ประวัติการเล่น ----------------

  /// บันทึกผลหนึ่งรอบ และเพิ่มขนมเข้ายอดสะสม
  Future<void> insertRun({required int distance, required int candies}) async {
    final d = await db;
    final score = distance + candies * 10;
    await d.transaction((txn) async {
      await txn.insert('play_history', {
        'score': score,
        'distance': distance,
        'candies': candies,
        'played_at': DateTime.now().toIso8601String(),
      });
      final rows = await txn.query(
        'profile',
        where: 'key = ?',
        whereArgs: ['candy_balance'],
      );
      final current = rows.isEmpty ? 0 : (rows.first['value'] as num).toInt();
      await txn.insert(
        'profile',
        {'key': 'candy_balance', 'value': current + candies},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<int> getBestDistance() async {
    final d = await db;
    final r = await d.rawQuery(
        'SELECT COALESCE(MAX(distance), 0) AS m FROM play_history');
    return (r.first['m'] as num).toInt();
  }

  Future<StatsSummary> getSummary() async {
    final d = await db;
    final agg = (await d.rawQuery('''
      SELECT COUNT(*) AS runs,
             COALESCE(MAX(distance), 0) AS best_d,
             COALESCE(MAX(score), 0) AS best_s,
             COALESCE(SUM(distance), 0) AS total_d,
             COALESCE(SUM(candies), 0) AS total_c
      FROM play_history
    ''')).first;

    final rows = await d.query('play_history', orderBy: 'id DESC', limit: 10);
    final recent = rows
        .map((r) => RunRecord(
              id: (r['id'] as num).toInt(),
              score: (r['score'] as num).toInt(),
              distance: (r['distance'] as num).toInt(),
              candies: (r['candies'] as num).toInt(),
              playedAt: DateTime.parse(r['played_at'] as String).toLocal(),
            ))
        .toList();

    return StatsSummary(
      runs: (agg['runs'] as num).toInt(),
      bestDistance: (agg['best_d'] as num).toInt(),
      bestScore: (agg['best_s'] as num).toInt(),
      totalDistance: (agg['total_d'] as num).toInt(),
      totalCandies: (agg['total_c'] as num).toInt(),
      balance: await getBalance(),
      recent: recent,
    );
  }

  // ---------------- ร้านสกิน ----------------

  Future<int> getBalance() async {
    final d = await db;
    final rows = await d.query(
      'profile',
      where: 'key = ?',
      whereArgs: ['candy_balance'],
    );
    return rows.isEmpty ? 0 : (rows.first['value'] as num).toInt();
  }

  /// สกินที่เป็นเจ้าของ (classic ได้ฟรีเสมอ)
  Future<Set<String>> getOwnedSkins() async {
    final d = await db;
    final rows = await d.query('owned_skins');
    return {'classic', ...rows.map((r) => r['id'] as String)};
  }

  Future<String> getSelectedSkin() async {
    final d = await db;
    final rows = await d.query(
      'owned_skins',
      where: 'selected = 1',
      limit: 1,
    );
    return rows.isEmpty ? 'classic' : rows.first['id'] as String;
  }

  /// ซื้อสกิน คืน true ถ้าสำเร็จ (ขนมพอและยังไม่เคยซื้อ)
  Future<bool> buySkin(String id, int price) async {
    final d = await db;
    return d.transaction<bool>((txn) async {
      final owned = await txn.query(
        'owned_skins',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (owned.isNotEmpty) return false;

      final bal = await txn.query(
        'profile',
        where: 'key = ?',
        whereArgs: ['candy_balance'],
      );
      final current = bal.isEmpty ? 0 : (bal.first['value'] as num).toInt();
      if (current < price) return false;

      await txn.insert(
        'profile',
        {'key': 'candy_balance', 'value': current - price},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert('owned_skins', {'id': id, 'selected': 0});
      return true;
    });
  }

  /// เลือกสกินที่ใช้ ('classic' = ไม่มีแถวไหนถูกเลือก)
  Future<void> selectSkin(String id) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.update('owned_skins', {'selected': 0});
      if (id != 'classic') {
        await txn.update(
          'owned_skins',
          {'selected': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }
}