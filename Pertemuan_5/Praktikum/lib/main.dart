import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/daftar_pengeluaran_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppPengeluaran());
}

class AppPengeluaran extends StatelessWidget {
  const AppPengeluaran({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Catatan Pengeluaran',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
    home: const HalamanNama(),
  );
}

class HalamanNama extends StatefulWidget {
  const HalamanNama({super.key});
  @override
  State<HalamanNama> createState() => _HalamanNamaState();
}

class _HalamanNamaState extends State<HalamanNama> {
  final nama = TextEditingController();
  bool loading = true;
  @override
  void initState() { super.initState(); muatNama(); }
  Future<void> muatNama() async {
    final p = await SharedPreferences.getInstance();
    nama.text = p.getString('nama_pengguna') ?? '';
    if (mounted) setState(() => loading = false);
  }
  Future<void> mulai() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('nama_pengguna', nama.text.trim());
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DaftarPengeluaranPage(nama: nama.text.trim())));
  }
  @override
  void dispose() { nama.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(appBar: AppBar(title: const Text('Praktikum 5 Flutter')),
      body: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.account_balance_wallet, size: 72, color: Colors.teal),
        const SizedBox(height: 16),
        const Text('Catatan Pengeluaran', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama pengguna', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: mulai, child: const Text('Mulai')))
      ])));
  }
}
