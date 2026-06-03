import 'package:flutter/material.dart';

class CartItem {
  final Map<String, dynamic> product;
  final String size;
  int quantity;

  CartItem({
    required this.product,
    required this.size,
    this.quantity = 1,
  });
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> items = [];

  void addItem(Map<String, dynamic> product, String size) {
    // Find if item with same name and size already exists
    for (var item in items) {
      if (item.product['name'] == product['name'] && item.size == size) {
        item.quantity++;
        notifyListeners();
        return;
      }
    }
    items.add(CartItem(product: product, size: size));
    notifyListeners();
  }

  void removeItem(CartItem item) {
    items.remove(item);
    notifyListeners();
  }

  void incrementQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      items.remove(item);
    }
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  int get totalItemsCount {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }

  double get subtotal {
    double total = 0;
    for (var item in items) {
      final priceStr = item.product['price'] as String? ?? '0';
      // Clean "1.490 TL" -> 1490.0
      final cleanPrice = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      total += cleanPrice * item.quantity;
    }
    return total;
  }

  double get deliveryFee {
    if (subtotal == 0) return 0;
    return subtotal > 500 ? 0 : 50;
  }

  double get total => subtotal + deliveryFee;
}
