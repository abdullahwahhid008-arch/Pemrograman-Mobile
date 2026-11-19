
import 'package:flutter/material.dart';
import '../services/health_service.dart';

class StatusServerPage extends StatefulWidget {
  const StatusServerPage({super.key});

  @override
  State<StatusServerPage> createState() =>
      _StatusServerPageState();
}

class _StatusServerPageState extends State<StatusServerPage> {
  final HealthService _healthService = HealthService();

  Map<String, dynamic>? _hasil;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    periksaServer();
  }

  Future<void> periksaServer() async {
    setState(() {
      _loading = true;
    });

    final hasil = await _healthService.checkHealth();

    if (!mounted) return;

    setState(() {
      _hasil = hasil;
      _loading = false;
    });
  }

  Widget kartuStatus(String judul, bool aktif, IconData ikon) {
    return Card(
      child: ListTile(
        leading: Icon(
          ikon,
          color: aktif ? Colors.green : Colors.red,
          size: 35,
        ),
        title: Text(judul),
        subtitle: Text(
          aktif ? 'Terhubung' : 'Tidak terhubung',
        ),
        trailing: Icon(
          aktif ? Icons.check_circle : Icons.cancel,
          color: aktif ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiAktif = _hasil?['api'] == true;
    final databaseAktif = _hasil?['database'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Server'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: periksaServer,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Koneksi TabungKu Cloud',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pemeriksaan koneksi server dan database.',
            ),
            const SizedBox(height: 20),

            kartuStatus(
              'API Server',
              apiAktif,
              Icons.cloud,
            ),

            kartuStatus(
              'Database MySQL',
              databaseAktif,
              Icons.storage,
            ),

            const SizedBox(height: 20),

            if (_hasil?['mysql_version'] != null)
              Text(
                'Versi MySQL: ${_hasil!['mysql_version']}',
              ),

            if (_hasil?['waktu_server'] != null)
              Text(
                'Waktu Server: ${_hasil!['waktu_server']}',
              ),

            if (_hasil?['detail'] != null)
              Text(
                'Keterangan: ${_hasil!['detail']}',
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: periksaServer,
              icon: const Icon(Icons.refresh),
              label: const Text('Periksa Koneksi'),
            ),
          ],
        ),
      ),
    );
  }
}
