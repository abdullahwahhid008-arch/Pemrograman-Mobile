
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// MODEL POSTINGAN
class Post {
  final int id;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

// MODEL KOMENTAR
class Komentar {
  final String name;
  final String email;
  final String body;

  Komentar({
    required this.name,
    required this.email,
    required this.body,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

// LAYANAN REST API
class ApiService {
  static const String baseUrl =
      'https://jsonplaceholder.typicode.com';

  static Future<List<Post>> getPosts() async {
    final response = await http
        .get(Uri.parse('$baseUrl/posts'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((item) => Post.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Gagal mengambil postingan: ${response.statusCode}',
      );
    }
  }

  static Future<List<Komentar>> getKomentar(int postId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/posts/$postId/comments'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((item) => Komentar.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Gagal mengambil komentar: ${response.statusCode}',
      );
    }
  }
}

// APLIKASI UTAMA
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daftar Postingan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DaftarPostinganPage(),
    );
  }
}

// HALAMAN DAFTAR POSTINGAN
class DaftarPostinganPage extends StatefulWidget {
  const DaftarPostinganPage({super.key});

  @override
  State<DaftarPostinganPage> createState() =>
      _DaftarPostinganPageState();
}

class _DaftarPostinganPageState
    extends State<DaftarPostinganPage> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = ApiService.getPosts();
  }

  void muatUlang() {
    setState(() {
      futurePosts = ApiService.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: muatUlang,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return TampilanError(
              pesan: snapshot.error.toString(),
              onRetry: muatUlang,
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text('Tidak ada data'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final future = ApiService.getPosts();
              setState(() {
                futurePosts = future;
              });
              await future;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${post.id}'),
                    ),
                    title: Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPostinganPage(post: post),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// HALAMAN DETAIL DAN KOMENTAR
class DetailPostinganPage extends StatefulWidget {
  final Post post;

  const DetailPostinganPage({
    super.key,
    required this.post,
  });

  @override
  State<DetailPostinganPage> createState() =>
      _DetailPostinganPageState();
}

class _DetailPostinganPageState
    extends State<DetailPostinganPage> {
  late Future<List<Komentar>> futureKomentar;

  @override
  void initState() {
    super.initState();
    futureKomentar =
        ApiService.getKomentar(widget.post.id);
  }

  void muatUlangKomentar() {
    setState(() {
      futureKomentar =
          ApiService.getKomentar(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Postingan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            post.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            post.body,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 32),
          Text(
            'Komentar',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Komentar>>(
            future: futureKomentar,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return TampilanError(
                  pesan: snapshot.error.toString(),
                  onRetry: muatUlangKomentar,
                );
              }

              final komentar = snapshot.data ?? [];

              if (komentar.isEmpty) {
                return const Text('Belum ada komentar.');
              }

              return Column(
                children: komentar.map((item) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.email,
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item.body),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// TAMPILAN ERROR DAN TOMBOL COBA LAGI
class TampilanError extends StatelessWidget {
  final String pesan;
  final VoidCallback onRetry;

  const TampilanError({
    super.key,
    required this.pesan,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pesan,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
