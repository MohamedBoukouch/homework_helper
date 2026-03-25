import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// ════════════════════════════════════════════════════════════════════════════
//  SCAN MODEL
// ════════════════════════════════════════════════════════════════════════════
class ScanRecord {
  final int? id;
  final String imagePath;
  final String result;
  final String status; // 'pending' | 'done' | 'error'
  final DateTime createdAt;

  const ScanRecord({
    this.id,
    required this.imagePath,
    required this.result,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'imagePath': imagePath,
    'result': result,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ScanRecord.fromMap(Map<String, dynamic> map) => ScanRecord(
    id: map['id'] as int?,
    imagePath: map['imagePath'] as String,
    result: map['result'] as String,
    status: map['status'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  ScanRecord copyWith({
    int? id,
    String? imagePath,
    String? result,
    String? status,
    DateTime? createdAt,
  }) => ScanRecord(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    result: result ?? this.result,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
}

// ════════════════════════════════════════════════════════════════════════════
//  DATABASE HELPER  (singleton)
// ════════════════════════════════════════════════════════════════════════════
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'scans.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scans (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            imagePath TEXT    NOT NULL,
            result    TEXT    NOT NULL DEFAULT '',
            status    TEXT    NOT NULL DEFAULT 'pending',
            createdAt TEXT    NOT NULL
          )
        ''');
      },
    );
  }

  // ── INSERT ────────────────────────────────────────────────────────────────
  Future<int> insertScan(ScanRecord scan) async {
    final db = await database;
    return db.insert('scans', scan.toMap());
  }

  // ── UPDATE result & status ────────────────────────────────────────────────
  Future<void> updateScan(int id, String result, String status) async {
    final db = await database;
    await db.update(
      'scans',
      {'result': result, 'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── GET ALL (newest first) ────────────────────────────────────────────────
  Future<List<ScanRecord>> getAllScans() async {
    final db = await database;
    final maps = await db.query('scans', orderBy: 'id DESC');
    return maps.map(ScanRecord.fromMap).toList();
  }

  // ── GET ONE ───────────────────────────────────────────────────────────────
  Future<ScanRecord?> getScan(int id) async {
    final db = await database;
    final maps = await db.query('scans', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ScanRecord.fromMap(maps.first);
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deleteScan(int id) async {
    final db = await database;
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  // ── DELETE ALL ────────────────────────────────────────────────────────────
  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('scans');
  }
}
