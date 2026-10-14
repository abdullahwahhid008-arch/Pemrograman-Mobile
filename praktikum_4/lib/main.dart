import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/daftar_pengeluaran_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PencatatPengeluaranApp());
}

class PencatatPengeluaranApp extends StatefulWidget {
  const PencatatPengeluaranApp({super.key});

  @override
  State<PencatatPengeluaranApp> createState() => _PencatatPengeluaranAppState();
}

class _PencatatPengeluaranAppState extends State<PencatatPengeluaranApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _ubahTema(bool nilai) async {
    setState(() {
      _isDarkMode = nilai;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', nilai);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: DaftarPengeluaranPage(
        isDarkMode: _isDarkMode,
        onThemeChanged: _ubahTema,
      ),
    );
  }
}