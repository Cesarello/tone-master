import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/tone_word.dart';

class LocalWordsDb {
  static const _dbName = 'words_cache.db';
  static const _table = 'words_cache';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pinyin TEXT NOT NULL,
            pinyin_with_tone TEXT NOT NULL,
            character TEXT NOT NULL,
            correct_tone INTEGER NOT NULL,
            translation TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<List<ToneWord>> getWords() async {
    final db = await database;
    final rows = await db.query(_table, orderBy: 'id ASC');
    return rows
        .map(
          (row) => ToneWord(
            pinyin: row['pinyin'] as String,
            pinyinWithTone: row['pinyin_with_tone'] as String,
            character: row['character'] as String,
            correctTone: row['correct_tone'] as int,
            translation: row['translation'] as String,
          ),
        )
        .toList(growable: false);
  }

  Future<void> replaceWords(List<ToneWord> words) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(_table);
      final batch = txn.batch();
      for (final word in words) {
        batch.insert(_table, {
          'pinyin': word.pinyin,
          'pinyin_with_tone': word.pinyinWithTone,
          'character': word.character,
          'correct_tone': word.correctTone,
          'translation': word.translation,
        });
      }
      await batch.commit(noResult: true);
    });
  }
}
