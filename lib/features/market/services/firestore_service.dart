import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ProductModel>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> seedProductsIfEmpty() async {
    try {
      final snapshot = await _db.collection('products').limit(2).get();
      bool isEmptyOrMockOnly = snapshot.docs.isEmpty;
      if (snapshot.docs.length == 1) {
        final data = snapshot.docs.first.data();
        if ((data['name']?.toString() ?? '').isEmpty) {
          isEmptyOrMockOnly = true;
          await _db.collection('products').doc(snapshot.docs.first.id).delete();
        }
      }

      if (isEmptyOrMockOnly) {
        final mockProducts = [
          {
            'name': 'Whey Gold Protein',
            'brand': 'Alpamys Nutrition',
            'category': 'Protein',
            'desc': 'Çikolatalı - 2.2 kg',
            'price': 1490,
            'rating': '4.9',
            'image': 'https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=300&auto=format&fit=crop&q=80',
            'isFavorite': false,
          },
          {
            'name': 'Creatine Micronized',
            'brand': 'Alpamys Nutrition',
            'category': 'Kreatin',
            'desc': 'Aromasız - 300g',
            'price': 790,
            'rating': '4.8',
            'image': 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=300&auto=format&fit=crop&q=80',
            'isFavorite': true,
          },
          {
            'name': 'BCAA Pro 2:1:1',
            'brand': 'Alpamys Nutrition',
            'category': 'Amino Asitler',
            'desc': 'Karpuzlu - 400g',
            'price': 890,
            'rating': '4.7',
            'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=300&auto=format&fit=crop&q=80',
            'isFavorite': false,
          },
          {
            'name': 'Mass Gainer Powder',
            'brand': 'Alpamys Nutrition',
            'category': 'Gainer',
            'desc': 'Muzlu - 3 kg',
            'price': 1290,
            'rating': '4.5',
            'image': 'https://images.unsplash.com/photo-1579758682665-53a1a614eea6?w=300&auto=format&fit=crop&q=80',
            'isFavorite': false,
          },
          {
            'name': 'Omega 3 Ultra Fish Oil',
            'brand': 'Alpamys Nutrition',
            'category': 'Vitaminler',
            'desc': '120 Yumuşak Kapsül',
            'price': 490,
            'rating': '4.8',
            'image': 'https://images.unsplash.com/photo-1611079830811-865ff1a44b73?w=300&auto=format&fit=crop&q=80',
            'isFavorite': true,
          },
          {
            'name': 'Pre-Workout Shox',
            'brand': 'Alpamys Nutrition',
            'category': 'Amino Asitler',
            'desc': 'Ekşi Elma - 300g',
            'price': 990,
            'rating': '4.9',
            'image': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=300&auto=format&fit=crop&q=80',
            'isFavorite': false,
          },
        ];

        for (var p in mockProducts) {
          await _db.collection('products').add(p);
        }
      }
    } catch (e) {
      // Ignore or log error
    }
  }
}
