import 'package:flutter/material.dart';
import 'package:perpus_flutter/components/app_bar.dart';
import 'package:perpus_flutter/components/bottom_nav_screen.dart';
import 'package:perpus_flutter/screens/usulan.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/usulan_provider.dart';
import 'package:perpus_flutter/components/riwayat_usulan_card.dart';

class RiwayatUsulan extends StatefulWidget {
  const RiwayatUsulan({super.key});

  @override
  State<RiwayatUsulan> createState() => _RiwayatUsulanState();
}

class _RiwayatUsulanState extends State<RiwayatUsulan> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load cache dulu
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<UsulanProvider>(
        context,
        listen: false,
      ).loadRiwayatUsulanFromCache();
      // Setelah itu fetch ke backend
      Provider.of<UsulanProvider>(context, listen: false).fetchRiwayatUsulan();
    });
  }

  Future<void> _handleDeleteAll() async {
    final usulanProvider = Provider.of<UsulanProvider>(context, listen: false);
    
    bool confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Yakin ingin menghapus SEMUA usulan? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sedang menghapus semua usulan...'),
          ],
        ),
      ),
    );

    try {
      await usulanProvider.deleteAllUsulan();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (usulanProvider.success) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Semua usulan berhasil dihapus'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );
      } else if (usulanProvider.errorMessage != null) {
        // Show error dialog
        await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Gagal'),
            content: Text(usulanProvider.errorMessage!),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still mounted
      if (mounted) Navigator.of(context).pop();

      // Show exception dialog
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Terjadi kesalahan yang tidak diketahui'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usulanProvider = Provider.of<UsulanProvider>(context);

    // Set controller text sesuai search terakhir
    _searchController.text = usulanProvider.searchQuery;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(),
      body: SafeArea(
        child: usulanProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await Provider.of<UsulanProvider>(
                    context,
                    listen: false,
                  ).fetchRiwayatUsulan(search: _searchController.text);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Row: Search bar + Hapus Semua button
                              Row(
                                children: [
                                  // Expanded Search bar
                                  Expanded(
                                    child: Material(
                                      elevation: 3,
                                      shadowColor: Colors.black26,
                                      borderRadius: BorderRadius.circular(12),
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          hintText: "Cari usulan ...",
                                          prefixIcon: const Icon(Icons.search),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        textInputAction: TextInputAction.search,
                                        onSubmitted: (value) {
                                          Provider.of<UsulanProvider>(
                                            context,
                                            listen: false,
                                          ).fetchRiwayatUsulan(search: value);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Hapus Semua Button
                                  if (usulanProvider.riwayatUsulan.isNotEmpty)
                                    ElevatedButton.icon(
                                      label: const Text("Hapus Semua"),
                                      icon: const Icon(Icons.delete),
                                      onPressed: _handleDeleteAll,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // List or empty message
                              if (usulanProvider.riwayatUsulan.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 80),
                                    child: Text(
                                      'Tidak ada data usulan.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: usulanProvider.riwayatUsulan.length,
                                  itemBuilder: (context, index) {
                                    final usulan =
                                        usulanProvider.riwayatUsulan[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: UsulanCard(usulan: usulan),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Usulan()),
          );
        },
        label: const Text(
          'Tambah Usulan',
          style: TextStyle(color: Color(0xFFF1F5F9)),
        ),
        icon: const Icon(Icons.add, color: Color(0xFFF1F5F9)),
        backgroundColor: Colors.blue[400],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50)),
      ),
      bottomNavigationBar: BottomNavComponent(
        selectedIndex: 2,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/buku');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/riwayatUsulan');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/informasi');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/profil');
          }
        },
      ),
    );
  }
}