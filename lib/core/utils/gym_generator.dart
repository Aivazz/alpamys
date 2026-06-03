import 'dart:math';

double calculateGymDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) *
          (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

List<Map<String, dynamic>> generateRealisticGyms(String cityName, double lat, double lon) {
  final List<String> unsplashGymImages = [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=500&auto=format&fit=crop&q=80',
  ];

  final int seed = cityName.codeUnits.fold(0, (prev, element) => prev + element);
  final Random rand = Random(seed);

  final List<String> gymNameTemplates = [
    'Fitness Center',
    'Sport Club',
    'Life & Sport Club',
    'Premium Fitness',
    'Gold Gym',
    'Champion Club',
    'Elite Fitness Center',
    'Dynamic Sport Club',
  ];

  final List<String> streets = [
    'Atatürk Caddesi',
    'Cumhuriyet Caddesi',
    'İstiklal Caddesi',
    'Fatih Sultan Mehmet Caddesi',
    'Bülent Ecevit Bulvarı',
    'Menderes Caddesi',
    'İnönü Caddesi',
    'Hürriyet Caddesi',
  ];

  List<Map<String, dynamic>> list = [];
  for (int i = 0; i < gymNameTemplates.length; i++) {
    final name = gymNameTemplates[i];
    
    final double latOffset = (rand.nextDouble() - 0.5) * 0.007;
    final double lonOffset = (rand.nextDouble() - 0.5) * 0.01;
    final double gymLat = lat + latOffset;
    final double gymLon = lon + lonOffset;

    final double dist = calculateGymDistance(lat, lon, gymLat, gymLon);
    final String street = streets[i % streets.length];
    final String address = '$street No: ${rand.nextInt(120) + 1}, $cityName';

    final image = unsplashGymImages[i % unsplashGymImages.length];
    final List<String> images = [
      image,
      unsplashGymImages[(i + 1) % unsplashGymImages.length],
      unsplashGymImages[(i + 2) % unsplashGymImages.length],
    ];

    final double rating = double.parse((4.2 + rand.nextDouble() * 0.7).toStringAsFixed(1));
    final int reviews = rand.nextInt(250) + 20;

    final String phone = '+90 378 ${rand.nextInt(900) + 100} ${rand.nextInt(9000) + 1000}';
    final String website = 'www.${gymNameTemplates[i].toLowerCase().replaceAll('&', '').replaceAll(' ', '')}$cityName.com'.toLowerCase();
    const priceTiers = [890, 990, 1090, 1190, 1290, 1390, 1490, 1590, 1690, 1790];
    final String approxPrice = '~${priceTiers[(seed + i) % priceTiers.length]} TL';
    
    final String gymDescription = '$name, $cityName şehrinin en popüler spor salonlarından biridir. Modern ekipmanları, güler yüzlü eğitmenleri ve geniş çalışma alanları ile hedeflerinize ulaşmanız için ideal bir ortam sunar. Adres: $address. Çalışma saatleri: 08:00 - 22:00. İletişim: $phone. Web sitesi: $website.';

    list.add({
      'id': 'gen_${cityName.toLowerCase()}_$i',
      'name': name,
      'image': image,
      'images': images,
      'rating': rating,
      'reviews': reviews,
      'distance': '${dist.toStringAsFixed(1)} km',
      'address': address,
      'price': approxPrice,
      'tags': ['Gym', if (i % 3 == 0) 'Pool', if (i % 4 == 0) 'Spa'],
      'latitude': gymLat,
      'longitude': gymLon,
      'description': gymDescription,
    });
  }

  return list;
}
