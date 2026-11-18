import 'package:flutter/material.dart';

import '../models/shopping.dart';
import '../services/wishlist_service.dart';
import 'detail_page.dart';
import 'shopping_tile.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist Anda')),
      body: ValueListenableBuilder<int>(
        valueListenable: WishlistService.changes,
        builder: (context, _, __) {
          return FutureBuilder<List<Shopping>>(
            future: WishlistService.getAll(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = snap.data!;
              if (products.isEmpty) {
                return const Center(child: Text('Wishlist masih kosong'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  return ShoppingTile(
                    product: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(productId: p.id),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await WishlistService.remove(p.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                            content: Text('Dihapus dari Wishlist'),
                            backgroundColor: Colors.red,
                          ));
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
