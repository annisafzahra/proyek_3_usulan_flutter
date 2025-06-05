import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/book_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:perpus_flutter/components/bottom_nav_screen.dart';
import 'package:perpus_flutter/components/info_card.dart';
import 'package:perpus_flutter/components/book_card.dart';
import 'package:perpus_flutter/components/app_bar.dart';
// import 'package:perpus_flutter/components/search_custom.dart';
// import 'package:perpus_flutter/components/category_chips.dart';
import 'package:perpus_flutter/screens/usulan.dart';
import 'package:perpus_flutter/models/book.dart';
import 'package:flutter/foundation.dart';
import 'package:perpus_flutter/providers/user_provider.dart'; // Tambahkan ini

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.13:8000/api/koleksi'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return compute(parseBooks, response.body);
    } else {
      throw Exception(
        'Gagal memuat buku: ${response.statusCode}\n${response.body}',
      );
    }
  }

  List<Book> parseBooks(String responseBody) {
    final List<dynamic> jsonData = json.decode(responseBody);
    return jsonData.map((book) => Book.fromJson(book)).toList();
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BookProvider>(context, listen: false);
    provider.loadBooksFromCache();
    Future.microtask(() => provider.fetchBooks());

    // Tambahkan ini untuk load user dari cache & backend
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUserFromCache();
    Future.microtask(() => userProvider.fetchUserData());
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final userProvider = Provider.of<UserProvider>(context); // Tambahkan ini

    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: CustomAppBar(),
          body: RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeText(userProvider), // Ubah di sini
                  InfoCard(
                    title: 'Selamat datang',
                    description:
                        'Di Perpustakaan Indramayu. Mari ajukan usulan buku!',
                    iconPath: 'assets/welcome.svg',
                  ),
                  InfoCard(
                    title: 'Pengusulan',
                    description:
                        'Saatnya mengusulkan buku agar koleksi perpustakaan semakin menarik!',
                    iconPath: 'assets/pengusulan_login.svg',
                    buttonText: "Sampaikan Judulmu!",
                    onButtonPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Usulan()),
                      );
                    },
                    iconOnLeft: true,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Koleksi Buku',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Consumer<BookProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (provider.errorMessage != null) {
                            return Center(child: Text(provider.errorMessage!));
                          } else if (provider.books.isEmpty) {
                            return const Center(child: Text('Tidak ada buku.'));
                          } else {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    bookProvider.books.map((book) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10.0,
                                        ),
                                        child: BookCard(book: book),
                                      );
                                    }).toList(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavComponent(
            selectedIndex: 0,
            onItemTapped: (index) {
              final routes = [
                '/dashboard',
                '/buku',
                '/riwayatUsulan',
                '/informasi',
                '/profil',
              ];
              Navigator.pushReplacementNamed(context, routes[index]);
            },
          ),
        );
      },
    );
  }

  // Ubah method ini agar menerima userProvider
  Widget _buildWelcomeText(UserProvider userProvider) {
    final userName = userProvider.username ?? 'Pengguna';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, $userName',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Ayo mulai mengusulkan buku.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
