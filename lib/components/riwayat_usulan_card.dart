import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/usulan_provider.dart';
import 'package:perpus_flutter/models/usulan.dart';
import 'package:perpus_flutter/config/config.dart';

class UsulanCard extends StatelessWidget {
  final UsulanModel usulan;

  const UsulanCard({super.key, required this.usulan});

  // Fungsi untuk kapitalisasi setiap kata (mirip aturan KBBI judul)
  String capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width - 32, // Account for padding
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBookInfo(context),
              const SizedBox(height: 12),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookImage() {
    if (usulan.bookImage == null || usulan.bookImage!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.book, size: 40),
      );
    }

    return Image.network(
      Config.fixImageUrl(usulan.bookImage!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value:
                loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
          ),
        );
      },
    );
  }

  Widget _buildBookInfo(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book Image with fixed size
        SizedBox(
          width: 80,
          height: 110,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildBookImage(),
          ),
        ),
        const SizedBox(width: 12),

        // Book Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Judul: ${capitalizeEachWord(usulan.bookTitle)}", // <-- gunakan fungsi di sini
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "ISBN: ${usulan.isbn}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Pengarang: ${usulan.author}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Kategori: ${usulan.genre}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "Tanggal: ${usulan.date}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate button width based on available space
        final buttonWidth =
            (constraints.maxWidth - 16) / 3; // 16 = total spacing

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(
              context,
              icon: Icons.visibility,
              label: "Detail",
              color: Colors.grey[600],
              width: buttonWidth,
              onPressed: () {
                Provider.of<UsulanProvider>(
                  context,
                  listen: false,
                ).setSelectedUsulan(usulan);
                Navigator.pushNamed(context, '/detailUsulan');
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.edit,
              label: "Edit",
              color: Colors.blue,
              width: buttonWidth,
              onPressed: () {
                Provider.of<UsulanProvider>(
                  context,
                  listen: false,
                ).setSelectedUsulan(usulan);
                Navigator.pushNamed(context, '/editUsulan');
              },
            ),
            _buildActionButton(
              context,
              icon: Icons.delete,
              label: "Hapus",
              color: Colors.red,
              width: buttonWidth,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color? color,
    required double width,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // ... rest of your methods (_confirmDelete, _deleteUsulan, etc.) remain the same ...

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus usulan ini?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Hapus'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteUsulan(context);
    }
  }

  Future<void> _deleteUsulan(BuildContext context) async {
    final usulanProvider = Provider.of<UsulanProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sedang menghapus usulan...'),
          ],
        ),
      ),
    );

    try {
      await usulanProvider.deleteUsulan(usulan.id);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (usulanProvider.success) {
        // Tampilkan SnackBar, bukan dialog
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usulan berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (usulanProvider.errorMessage != null) {
        await _showErrorDialog(context, usulanProvider.errorMessage!);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      await _showErrorDialog(context, 'Terjadi kesalahan yang tidak diketahui');
    }
  }

  Future<void> _showSuccessDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Berhasil'),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }
}
