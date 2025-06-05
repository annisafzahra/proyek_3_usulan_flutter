import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:perpus_flutter/providers/usulan_provider.dart';

class Usulan extends StatefulWidget {
  const Usulan({super.key});

  @override
  State<Usulan> createState() => _UsulanState();
}

class _UsulanState extends State<Usulan> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _pengarangController = TextEditingController();
  final TextEditingController _penerbitController = TextEditingController();
  final TextEditingController _tahunTerbitController = TextEditingController();
  final TextEditingController _tanggalUsulanController =
      TextEditingController();

  String? _selectedKategori;
  final List<String> _kategoriList = [
    'Self Improvement',
    'Fiksi Sejarah',
    'Puisi',
    'Sejarah',
  ];

  File? _selectedImage;

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 170, 173, 174),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 207, 211, 216),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedKategori,
        onChanged: (value) {
          setState(() {
            _selectedKategori = value;
          });
        },
        items:
            _kategoriList.map((kategori) {
              return DropdownMenuItem<String>(
                value: kategori,
                child: Text(kategori),
              );
            }).toList(),
        decoration: InputDecoration(
          labelText: 'Kategori',
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 207, 211, 216),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _tanggalUsulanController.text = picked.toString().split(' ')[0];
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(_tanggalUsulanController, 'Tanggal Usulan'),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gambar Buku",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedImage = File(picked.path);
                      });
                      print("Path gambar: ${picked.path}");
                    } else {
                      print("Tidak ada gambar yang dipilih.");
                    }
                  } catch (e) {
                    print("Terjadi kesalahan saat memilih gambar: $e");
                  }
                },

                child: const Text('Pilih Gambar'),
              ),
              const SizedBox(width: 16),
              _selectedImage != null
                  ? Image.file(
                    _selectedImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                  : const Text("Belum ada gambar"),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshForm() async {
    // Reset semua form input dan image
    setState(() {
      _judulController.clear();
      _isbnController.clear();
      _pengarangController.clear();
      _penerbitController.clear();
      _tahunTerbitController.clear();
      _tanggalUsulanController.clear();
      _selectedKategori = null;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usulan"),
        backgroundColor: const Color(0xFF60A5FA),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _refreshForm,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(_judulController, "Judul Buku"),
              _buildDropdownField(),
              _buildTextField(
                _isbnController,
                "ISBN",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(_pengarangController, "Pengarang"),
              _buildTextField(_penerbitController, "Penerbit"),
              _buildTextField(
                _tahunTerbitController,
                "Tahun Terbit",
                keyboardType: TextInputType.number,
              ),
              _buildDateField(),
              _buildImagePicker(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    final usulanProvider = Provider.of<UsulanProvider>(
                      context,
                      listen: false,
                    );

                    await usulanProvider.kirimUsulan(
                      bookTitle: _judulController.text.toLowerCase(),
                      genre: _selectedKategori ?? '',
                      isbn: _isbnController.text,
                      author: _pengarangController.text,
                      publisher: _penerbitController.text,
                      publicationYear: _tahunTerbitController.text,
                      date: _tanggalUsulanController.text,
                      bookImage: _selectedImage,
                    );

                    if (usulanProvider.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usulan berhasil dikirim!'),
                        ),
                      );
                      Navigator.pop(context, true);
                    } else {
                      // Cek jika error karena duplikat
                      if ((usulanProvider.errorMessage ?? '')
                              .toLowerCase()
                              .contains('duplikat') ||
                          (usulanProvider.errorMessage ?? '')
                              .toLowerCase()
                              .contains('sudah pernah')) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Peringatan'),
                                content: const Text(
                                  'Judul buku sudah pernah diusulkan, tidak boleh duplikasi!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              usulanProvider.errorMessage ??
                                  'Terjadi kesalahan',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Kirim", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
