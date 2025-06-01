class ProductModel {
  final String id;
  final String name;
  final String price; // Format: "8.00 TND"
  final String image;
  final String description;
  final String artisanId; // Changed from artisan to artisanId
  final String category; // ✅ AJOUTÉ
  final bool isOnPromotion;
  final double? promotionPercentage;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.artisanId, // Changed from artisan to artisanId
    required this.category, // ✅ AJOU
    this.isOnPromotion = false,
    this.promotionPercentage,
  });

  double get discountedPrice {
    if (!isOnPromotion || promotionPercentage == null)
      return getPriceAsDouble();
    return getPriceAsDouble() * (1 - promotionPercentage! / 100);
  }

  // Convertir une Map (ex: venant de Firestore) en ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    // Traiter le prix
    String priceStr = map['price']?.toString() ?? '0';
    priceStr = priceStr.replaceAll('TND', '').trim();
    if (priceStr.contains('.') && priceStr.contains(',')) {
      if (priceStr.indexOf('.') < priceStr.indexOf(',')) {
        priceStr = priceStr.replaceAll('.', '').replaceAll(',', '.');
      }
    } else {
      priceStr = priceStr.replaceAll(',', '.');
    }
    double priceValue = double.tryParse(priceStr) ?? 0.0;
    String formattedPrice = '${priceValue.toStringAsFixed(2)} TND';

    // Prendre la première image de imageUrls si elle existe
    String imageUrl = '';
    if (map['imageUrls'] != null &&
        map['imageUrls'] is List &&
        (map['imageUrls'] as List).isNotEmpty) {
      imageUrl = (map['imageUrls'] as List).first;
    } else if (map['image'] != null) {
      imageUrl = map['image'];
    }

    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      price: formattedPrice,
      image: imageUrl,
      description: map['description'] ?? '',
      artisanId: map['artisanId'] ?? '', // Changed from artisan to artisanId
      category: map['category'] ?? '',
      isOnPromotion: map['isOnPromotion'] ?? false,
      promotionPercentage: (map['promotionPercentage'] as num?)?.toDouble(),
    );
  }

  // Convertir un ProductModel en Map (ex: pour envoyer à Firestore)
  Map<String, dynamic> toMap() {
    // Extraire seulement la valeur numérique du prix
    double priceValue = getPriceAsDouble();
    return {
      'name': name,
      'price': priceValue.toStringAsFixed(2), // Stocker sans 'TND'
      'image': image,
      'description': description,
      'artisanId': artisanId, // Changed from artisan to artisanId
      'category': category, // ✅ Ajouté
      'isOnPromotion': isOnPromotion,
      'promotionPercentage': promotionPercentage,
    };
  }

  // Helper method to get price as double
  double getPriceAsDouble() {
    // Supprimer 'TND' et les espaces, puis convertir en double
    String numericPrice = price.replaceAll('TND', '').trim();

    // Traitement spécial pour les grands nombres (ex: 1.234,56)
    if (numericPrice.contains('.') && numericPrice.contains(',')) {
      // Si le point vient avant la virgule, c'est un séparateur de milliers
      if (numericPrice.indexOf('.') < numericPrice.indexOf(',')) {
        numericPrice = numericPrice.replaceAll('.', '').replaceAll(',', '.');
      }
    } else {
      // Cas normal : remplacer la virgule par un point
      numericPrice = numericPrice.replaceAll(',', '.');
    }

    return double.tryParse(numericPrice) ?? 0.0;
  }

  // Helper method to format price with currency
  String getFormattedPrice() {
    double priceValue = getPriceAsDouble();
    return '${priceValue.toStringAsFixed(2)} TND';
  }
}
