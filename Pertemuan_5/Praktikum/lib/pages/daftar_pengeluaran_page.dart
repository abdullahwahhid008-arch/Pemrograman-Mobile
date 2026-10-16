import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/pengeluaran.dart';
import 'form_pengeluaran_page.dart';

class DaftarPengeluaranPage extends StatefulWidget {
  final String nama;
  const DaftarPengeluaranPage({super.key, required this.nama});
  @override
  State<DaftarPengeluaranPage> createState() => _DaftarPengeluaranPageState();
}
class _DaftarPengeluaranPageState extends State<DaftarPengeluaranPage> {
  late Future<List<Pengeluaran>> data;
  @override
  void initState() { super.initState(); muat(); }
  void muat() { data = DbHelper.instance.semua(); }
  String rupiah(int n) {
    final s = n.toString(); final out = StringBuffer();
    for (var i=0; i<s.length; i++) { out.write(s[i]); final r=s.length-i-1; if (r>0 && r%3==0) out.write('.'); }
    return 'Rp$out';
  }
  Future<void> tambah() async {
    final p = await Navigator.push<Pengeluaran>(context, MaterialPageRoute(builder: (_) => const FormPengeluaranPage()));
    if (p != null) { await DbHelper.instance.tambah(p); if (mounted) setState(muat); }
  }
  Future<void> edit(Pengeluaran item) async {
    final p = await Navigator.push<Pengeluaran>(context, MaterialPageRoute(builder: (_) => FormPengeluaranPage(item: item)));
    if (p != null) { await DbHelper.instance.ubah(p); if (mounted) setState(muat); }
  }
  Future<void> hapus(Pengeluaran item) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Hapus pengeluaran?'), content: Text('Hapus ${item.judul}?'),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Batal')),
      FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Hapus'))]));
    if (ok == true && item.id != null) { await DbHelper.instance.hapus(item.id!); if (mounted) setState(muat); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daftar Pengeluaran')),
    floatingActionButton: FloatingActionButton.extended(onPressed: tambah, icon: const Icon(Icons.add), label: const Text('Tambah')),
    body: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(18), color: Theme.of(context).colorScheme.primaryContainer,
        child: Text('Halo, ${widget.nama.isEmpty ? 'Pengguna' : widget.nama}!\nCatat pengeluaranmu.', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
      Expanded(child: FutureBuilder<List<Pengeluaran>>(future: data, builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final items = snap.data ?? [];
        if (items.isEmpty) return const Center(child: Text('Belum ada pengeluaran.\nTekan Tambah untuk memulai.', textAlign: TextAlign.center));
        final total = items.fold<int>(0, (s, p) => s+p.jumlah);
        return Column(children: [
          ListTile(title: const Text('Total pengeluaran'), trailing: Text(rupiah(total), style: const TextStyle(fontWeight: FontWeight.bold))),
          const Divider(height: 1),
          Expanded(child: ListView.builder(itemCount: items.length, itemBuilder: (_, i) {
            final p = items[i];
            return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.payments)), title: Text(p.judul),
              subtitle: Text('${rupiah(p.jumlah)} • ${p.tanggal}\n${p.catatan.isEmpty ? 'Tanpa catatan' : p.catatan}'),
              isThreeLine: true, onTap: () => edit(p),
              trailing: PopupMenuButton<String>(onSelected: (v) => v == 'edit' ? edit(p) : hapus(p),
                itemBuilder: (_) => const [PopupMenuItem(value:'edit', child: Text('Edit')), PopupMenuItem(value:'hapus', child: Text('Hapus'))])
            ));
          }))
        ]);
      }))
    ]));
}
