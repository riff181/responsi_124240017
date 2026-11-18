import 'package:flutter/material.dart';

import '../models/shopping.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import 'detail_page.dart';
import 'login_page.dart';
import 'shopping_tile.dart';
import 'wishlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Shopping>> _products;
  late final Future<List<String>> _categories;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _categories = ApiService.fetchCategories();
    _products = ApiService.fetchProducts();
  }

  void _load() {
    setState(() {
      _products = ApiService.fetchProducts(category: _selected);
    });
  }

  void _select(String? category) {
    _selected = category;
    _load();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget _categoryBar() => FutureBuilder<List<String>>(
    future: _categories,
    builder: (context, snap) {
      if (!snap.hasData) return const SizedBox(height: 8);
      final cats = snap.data!;
      return SizedBox(
        height: 52,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            _chip('Semua', _selected == null, () => _select(null)),
            for (final c in cats)
              _chip(prettyCategory(c), _selected == c, () => _select(c)),
          ],
        ),
      );
    },
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.light,
      onSelected: (_) => onTap(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${AuthService.username}'),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistPage()),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _categoryBar(),
          Expanded(
            child: FutureBuilder<List<Shopping>>(
              future: _products,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Gagal memuat data'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: _load,
                            child: const Text('Coba lagi'),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final products = snap.data!;
                if (products.isEmpty) {
                  return const Center(child: Text('Produk tidak ditemukan'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ShoppingTile(
                    product: products[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(productId: products[i].id),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
