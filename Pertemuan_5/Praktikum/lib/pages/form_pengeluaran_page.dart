import 'package:flutter/material.dart';
import '../models/pengeluaran.dart';

class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? item;
  const FormPengeluaranPage({super.key, this.item});
  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}
class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final form = GlobalKey<FormState>();
  late final judul = TextEditingController(text: widget.item?.judul ?? '');
  late final jumlah = TextEditingController(text: widget.item?.jumlah.toString() ?? '');
  late final catatan = TextEditingController(text: widget.item?.catatan ?? '');
  late DateTime tanggal = DateTime.tryParse(widget.item?.tanggal ?? '') ?? DateTime.now();
  String get tanggalText => '${tanggal.year}-${tanggal.month.toString().padLeft(2,'0')}-${tanggal.day.toString().padLeft(2,'0')}';
  @override
  void dispose() { judul.dispose(); jumlah.dispose(); catatan.dispose(); super.dispose(); }
  Future<void> pilihTanggal() async {
    final d = await showDatePicker(context: context, initialDate: tanggal, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (d != null) setState(() => tanggal = d);
  }
  void simpan() {
    if (!form.currentState!.validate()) return;
    Navigator.pop(context, Pengeluaran(id: widget.item?.id, judul: judul.text.trim(),
      jumlah: int.parse(jumlah.text), tanggal: tanggalText, catatan: catatan.text.trim()));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.item == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran')),
    body: Form(key: form, child: ListView(padding: const EdgeInsets.all(20), children: [
      TextFormField(controller: judul, decoration: const InputDecoration(labelText: 'Nama pengeluaran', border: OutlineInputBorder()),
        validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null),
      const SizedBox(height: 14),
      TextFormField(controller: jumlah, keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Jumlah (rupiah)', border: OutlineInputBorder()),
        validator: (v) { final n = int.tryParse(v ?? ''); return n == null || n <= 0 ? 'Masukkan jumlah yang valid' : null; }),
      const SizedBox(height: 14),
      OutlinedButton.icon(onPressed: pilihTanggal, icon: const Icon(Icons.calendar_month), label: Text('Tanggal: $tanggalText')),
      const SizedBox(height: 14),
      TextFormField(controller: catatan, maxLines: 3, decoration: const InputDecoration(labelText: 'Catatan (opsional)', border: OutlineInputBorder())),
      const SizedBox(height: 20),
      FilledButton.icon(onPressed: simpan, icon: const Icon(Icons.save), label: const Text('Simpan'))
    ])));
}
