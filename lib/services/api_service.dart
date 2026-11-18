import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shopping.dart';

class ApiService {
  static const String _base = 'https://dummyjson.com/products';
  static const int _limit = 20;

  static Future<dynamic> _get(String url, String errMsg) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('$errMsg (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  static Future<List<Shopping>> fetchProducts({String? category}) async {
    final url = category == null
        ? '$_base?limit=$_limit'
        : '$_base/category/$category?limit=$_limit';
    final data = await _get(url, 'Gagal memuat daftar produk');
    final List list = data['products'];
    return list
        .map((e) => Shopping.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ShoppingDetail> fetchDetail(int id) async {
    final data = await _get('$_base/$id', 'Gagal memuat detail produk');
    return ShoppingDetail.fromJson(data as Map<String, dynamic>);
  }

  static Future<List<String>> fetchCategories() async {
    final data = await _get('$_base/category-list', 'Gagal memuat kategori');
    return List<String>.from(data);
  }
}
