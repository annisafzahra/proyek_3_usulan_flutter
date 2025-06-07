import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          isScrollControlled: true,
          builder: (_) => BookDetailModal(
            title: book.title,
            image: book.image,
            isbn: book.isbn,
            description: book.description,
            author: book.author,
            publisher: book.publisher,
            publicationYear: book.publicationYear,
            synopsis: book.synopsis,
            genre: book.genre,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        width: 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.image != null
                    ? Image.network(book.image!, fit: BoxFit.cover)
                    : const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailModal extends StatelessWidget {
  final String title;
  final String? image;
  final String isbn;
  final String description;
  final String author;
  final String publisher;
  final String publicationYear;
  final String synopsis;
  final String genre;

  const BookDetailModal({
    super.key,
    required this.title,
    this.image,
    required this.isbn,
    required this.description,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.synopsis,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Detail Buku",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Book cover
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image != null
                    ? Image.network(image!, height: 300)
                    : const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(height: 12),

              // Title & author
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(author, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),

              // Publisher & Year
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Penerbit",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(publisher),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "ISBN",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(isbn),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Deskripsi",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('$description halaman'),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Tahun",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(publicationYear),
                    ],
                  ),
                ],
              ),

              // Sinopsis
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sinopsis",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(synopsis, textAlign: TextAlign.justify),
              const SizedBox(height: 20),

              // Genre
              Wrap(spacing: 12, children: [Chip(label: Text(genre))]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}