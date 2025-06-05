// screens/notifikasi_screen.dart
import 'package:flutter/material.dart';
import 'package:perpus_flutter/models/notification.dart';
import 'package:perpus_flutter/services/notification_service.dart';
import 'dart:convert' as json;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  NotifikasiScreenState createState() => NotifikasiScreenState();
}

class NotifikasiScreenState extends State<NotifikasiScreen> {
  final NotificationService _notificationService = NotificationService();
  final Logger _logger = Logger();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationService.fetchNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Hapus Semua Notifikasi?'),
                      content: const Text(
                        'Apakah Anda yakin ingin menghapus semua notifikasi?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                try {
                  await _notificationService.deleteAllNotifications();
                  setState(() {
                    _notifications.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua notifikasi dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e, stackTrace) {
                  String errorMsg = e.toString();
                  // Jika error dari http.Response, ambil pesan dari body
                  if (e is http.Response) {
                    try {
                      final data = json.json.decode(e.body);
                      errorMsg = data['message'] ?? errorMsg;
                    } catch (_) {}
                  }
                  // Log error ke konsol
                  _logger.e(
                    'Gagal menghapus notifikasi: $errorMsg',
                    error: e,
                    stackTrace: stackTrace,
                  );

                  // Tampilkan pesan error ke user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus notifikasi: $errorMsg'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text('Tidak ada notifikasi'));
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: const Color.fromARGB(255, 98, 169, 240),
          child: ListTile(
            title: Row(
              children: [
                const Text(
                  'Judul buku: ',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  '${notification.data['bookTitle'] ?? 'No Title'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.data['message'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  notification.createdAt,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
