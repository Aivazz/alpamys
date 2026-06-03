import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderItem {
  final String id;
  final String productName;
  final String productImage;
  final String price;
  final String size;
  final int quantity;
  final DateTime orderedAt;
  final String status; // 'delivered', 'in_transit', 'processing'

  OrderItem({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.size,
    required this.quantity,
    required this.orderedAt,
    this.status = 'delivered',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'productImage': productImage,
        'price': price,
        'size': size,
        'quantity': quantity,
        'orderedAt': orderedAt.toIso8601String(),
        'status': status,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as String,
        productName: json['productName'] as String,
        productImage: json['productImage'] as String? ?? '',
        price: json['price'] as String,
        size: json['size'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        orderedAt: DateTime.parse(json['orderedAt'] as String),
        status: json['status'] as String? ?? 'delivered',
      );
}

class OrderHistoryService extends ChangeNotifier {
  static final OrderHistoryService _instance = OrderHistoryService._internal();
  factory OrderHistoryService() => _instance;
  OrderHistoryService._internal();

  List<OrderItem> _orders = [];
  List<OrderItem> get orders => List.unmodifiable(_orders);

  static const String _key = 'order_history_v1';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _orders = raw.map((e) => OrderItem.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
    _orders.sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
    notifyListeners();
  }

  Future<void> addOrder(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    for (final item in cartItems) {
      final order = OrderItem(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}_${item['name']}',
        productName: item['name']?.toString() ?? 'Ürün',
        productImage: item['image']?.toString() ?? '',
        price: item['price']?.toString() ?? '0 TL',
        size: item['size']?.toString() ?? '',
        quantity: (item['quantity'] as int?) ?? 1,
        orderedAt: DateTime.now(),
        status: 'in_transit',
      );
      _orders.insert(0, order);
    }
    await prefs.setStringList(_key, _orders.map((e) => jsonEncode(e.toJson())).toList());
    notifyListeners();
  }
}
