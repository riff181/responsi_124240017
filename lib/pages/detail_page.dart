import 'package:flutter/material.dart';

import '../models/shopping.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';
import '../theme.dart';

class DetailPage extends StatefulWidget {
  final int productId;
  const DetailPage({super.key, required this.productId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<ShoppingDetail> _future;
  bool _inWishlist = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchDetail(widget.productId);
    WishlistService.has(widget.productId).then((v) {
      if (mounted) setState(() => _inWishlist = v);
    });
  }

  Widget _meta(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _chip(String text, {bool filled = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: filled ? AppColors.light : Colors.transparent,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );

  Future<void> _toggleWishlist(ShoppingDetail p) async {
    final added = await WishlistService.toggle(p.toShopping());
    if (!mounted) return;
    setState(() => _inWishlist = added);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(added
            ? 'Produk ditambahkan ke Wishlist'
            : 'Produk dihapus dari Wishlist'),
        backgroundColor: added ? Colors.green : Colors.red,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: FutureBuilder<ShoppingDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Gagal memuat detail produk'));
          }
          final p = snap.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.card,
                  width: double.infinity,
                  child: Image.network(
                    p.mainImage,
                    height: 260,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 260,
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _chip(prettyCategory(p.category), filled: true),
                          const SizedBox(width: 8),
                          _chip('Brand: ${p.brand}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _meta('Harga', '\$${p.price.toStringAsFixed(2)}'),
                          _meta('Diskon',
                              '${p.discountPercentage.toStringAsFixed(1)}%'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _meta('Rating', '${p.rating.toStringAsFixed(1)} / 5'),
                          _meta('Stok', '${p.stock}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _toggleWishlist(p),
                        icon: Icon(
                          _inWishlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _inWishlist ? Colors.redAccent : null,
                        ),
                        label: Text(_inWishlist
                            ? 'Hapus dari Wishlist'
                            : 'Tambah ke Wishlist'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Deskripsi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(p.description, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
