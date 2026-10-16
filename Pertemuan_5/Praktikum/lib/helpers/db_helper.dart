import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pengeluaran.dart';

class DbHelper {
  DbHelper._();
  static final instance = DbHelper._();
  Database? _db;
  Future<Database> get database async => _db ??= await _buka();
  Future<Database> _buka() async {
    final lokasi = join(await getDatabasesPath(), 'pengeluaran.db');
    return openDatabase(lokasi, version: 1, onCreate: (db, v) async {
      await db.execute('CREATE TABLE pengeluaran(id INTEGER PRIMARY KEY AUTOINCREMENT, judul TEXT NOT NULL, jumlah INTEGER NOT NULL, tanggal TEXT NOT NULL, catatan TEXT NOT NULL DEFAULT \'\')');
    });
  }
  Future<int> tambah(Pengeluaran p) async => (await database).insert('pengeluaran', p.toMap());
  Future<List<Pengeluaran>> semua() async => (await (await database).query('pengeluaran', orderBy: 'id DESC')).map(Pengeluaran.fromMap).toList();
  Future<int> ubah(Pengeluaran p) async => (await database).update('pengeluaran', p.toMap(), where: 'id=?', whereArgs: [p.id]);
  Future<int> hapus(int id) async => (await database).delete('pengeluaran', where: 'id=?', whereArgs: [id]);
}
