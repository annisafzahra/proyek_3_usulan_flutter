class Config {
  static const String ip = '192.168.100.15:8000';

  // Untuk endpoint API
  static String baseUrl(String path) => 'http://$ip/api/$path';

  // Untuk path gambar usulan
  static String fixImageUrl(String url) {
    if (url.contains('usulan/usulan/')) {
      // Perbaiki URL dengan menghapus duplikasi 'usulan/usulan/'
      return url.replaceFirst('usulan/usulan/', 'usulan/');
    }
    return url;
  }
}