class Pengeluaran {
  final int? id;
  final String judul;
  final int jumlah;
  final String tanggal;
  final String catatan;
  const Pengeluaran({this.id, required this.judul, required this.jumlah, required this.tanggal, this.catatan = ''});
  Map<String, Object?> toMap() => {'id': id, 'judul': judul, 'jumlah': jumlah, 'tanggal': tanggal, 'catatan': catatan};
  factory Pengeluaran.fromMap(Map<String, Object?> m) => Pengeluaran(
    id: m['id'] as int?, judul: m['judul'] as String, jumlah: m['jumlah'] as int,
    tanggal: m['tanggal'] as String, catatan: (m['catatan'] as String?) ?? '');
}
