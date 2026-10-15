import 'package:flutter/material.dart';
import '../models/pengeluaran.dart';
import '../helpers/db_helper.dart';

class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? pengeluaran;

  const FormPengeluaranPage({super.key, this.pengeluaran});

  @override
  State<FormPengeluaranPage> createState() => _FormPengeluaranPageState();
}

class _FormPengeluaranPageState extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _tanggalController;
  String _kategoriPilihan = 'Makanan';

  final List<String> _kategoriList = ['Makanan', 'Transportasi', 'Belanja', 'Hiburan', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.pengeluaran?.nama ?? '');
    _jumlahController = TextEditingController(text: widget.pengeluaran?.jumlah.toString() ?? '');
    _tanggalController = TextEditingController(
      text: widget.pengeluaran?.tanggal ?? DateTime.now().toString().substring(0, 10),
    );
    if (widget.pengeluaran != null && _kategoriList.contains(widget.pengeluaran!.kategori)) {
      _kategoriPilihan = widget.pengeluaran!.kategori;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate()) return;

    final pengeluaranBaru = Pengeluaran(
      id: widget.pengeluaran?.id,
      nama: _namaController.text.trim(),
      jumlah: int.parse(_jumlahController.text.trim()),
      kategori: _kategoriPilihan,
      tanggal: _tanggalController.text.trim(),
    );

    if (widget.pengeluaran == null) {
      await DbHelper.tambah(pengeluaranBaru);
    } else {
      await DbHelper.ubah(pengeluaranBaru);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pengeluaran != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Ubah Pengeluaran' : 'Tambah Pengeluaran')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Pengeluaran', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (Angka)', border: OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Jumlah wajib diisi';
                final angka = int.tryParse(v);
                if (angka == null || angka <= 0) return 'Masukkan angka lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategoriPilihan,
              decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
              items: _kategoriList.map((kat) {
                return DropdownMenuItem(value: kat, child: Text(kat));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _kategoriPilihan = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tanggalController,
              decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Tanggal wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _simpanData,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Simpan Pengeluaran', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}