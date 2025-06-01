import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final RxBool isLoading = false.obs;
  final RxList orders = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final QuerySnapshot ordersSnapshot =
          await _firestore.collection('orders').get();
      orders.value = ordersSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Statistiques
  int get totalOrders => orders.length;

  double get totalRevenue {
    return orders.fold(0.0, (sum, order) => sum + (order['total'] ?? 0.0));
  }

  int get uniqueCustomers {
    final customerIds = orders.map((order) => order['customerId']).toSet();
    return customerIds.length;
  }

  int get pendingOrders {
    return orders.where((order) => order['status'] == 'pending').length;
  }

  int get deliveredOrders {
    return orders.where((order) => order['status'] == 'delivered').length;
  }

  int get cancelledOrders {
    return orders.where((order) => order['status'] == 'cancelled').length;
  }

  double get satisfactionRate {
    final ratedOrders = orders.where((order) => order['rating'] != null);
    if (ratedOrders.isEmpty) return 0;
    final totalRating = ratedOrders.fold(
      0.0,
      (sum, order) => sum + (order['rating'] ?? 0.0),
    );
    return totalRating / ratedOrders.length;
  }

  // Données pour le graphique des ventes
  List<Map<String, dynamic>> getSalesData(String period) {
    // TODO: Implémenter la logique pour obtenir les données de vente selon la période
    return [];
  }

  // Statistiques par catégorie
  Map<String, double> getCategoryStats() {
    final Map<String, double> stats = {};
    final totalProducts = orders.fold<int>(
      0,
      (sum, order) => sum + ((order['products']?.length ?? 0) as int),
    );

    for (var order in orders) {
      final products = order['products'] ?? [];
      for (var product in products) {
        final category = product['category'];
        if (category != null) {
          stats[category] = (stats[category] ?? 0) + 1;
        }
      }
    }

    // Convertir en pourcentages
    if (totalProducts > 0) {
      stats.forEach((key, value) {
        stats[key] = (value / totalProducts) * 100;
      });
    }

    return stats;
  }

  Future<String> createOrder({
    required List<ProductModel> products,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required String deliveryCity,
    required String postalCode,
    required String? additionalInfo,
    required GeoPoint deliveryLocation,
    required double deliveryFee,
  }) async {
    try {
      isLoading.value = true;

      final String orderId = const Uuid().v4();
      final String userId = _authController.firebaseUser.value?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('Utilisateur non connecté');
      }

      // Générer les listes d'IDs produits et artisans
      final productIds = products.map((p) => p.id).toSet().toList();
      final artisanIds = products.map((p) => p.artisanId).toSet().toList();

      // Calcul du prix total des produits
      final double productsTotal = products.fold(
        0.0,
        (sum, p) => sum + p.getPriceAsDouble(),
      );

      final order = OrderModel(
        id: orderId,
        userId: userId,
        productId:
            productIds.length == 1
                ? productIds.first
                : 'cart_${DateTime.now().millisecondsSinceEpoch}',
        productIds: productIds,
        productName:
            productIds.length == 1 ? products.first.name : 'Commande multiple',
        productPrice: productsTotal,
        quantity: products.length,
        deliveryFee: deliveryFee,
        totalAmount: productsTotal + deliveryFee,
        customerName: customerName,
        customerPhone: customerPhone,
        deliveryAddress: deliveryAddress,
        deliveryCity: deliveryCity,
        postalCode: postalCode,
        additionalInfo: additionalInfo,
        deliveryLocation: deliveryLocation,
        status: 'pending',
        createdAt: DateTime.now(),
        artisanId:
            artisanIds.length == 1 ? artisanIds.first : 'multiple_artisans',
        artisanIds: artisanIds,
      );

      await _firestore.collection('orders').doc(orderId).set(order.toMap());
      return orderId;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer la commande: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Revenu total de l'artisan connecté
  double getTotalRevenueForArtisan(String artisanId) {
    print(
      'Calcul du revenu pour $artisanId sur [33m${orders.length}[0m commandes',
    );
    double total = 0.0;
    for (var order in orders) {
      if ((order['artisanIds'] ?? []).contains(artisanId)) {
        int nbArtisans = (order['artisanIds'] as List).length;
        total += (order['totalAmount'] ?? 0.0) / nbArtisans;
      }
    }
    print('Revenu calculé: $total');
    return total;
  }

  // Mapping {productId: nombre de ventes} pour un artisan
  Map<String, int> getProductSalesCountForArtisan(String artisanId) {
    final Map<String, int> sales = {};
    for (var order in orders) {
      if ((order['artisanIds'] ?? []).contains(artisanId)) {
        final List<dynamic> pids = order['productIds'] ?? [];
        for (var pid in pids) {
          // Ici, il faudrait idéalement vérifier que le produit appartient bien à l'artisan
          // Si tu veux une vérification stricte, il faut stocker la correspondance produit/artisan dans la base
          sales[pid] = (sales[pid] ?? 0) + 1;
        }
      }
    }
    return sales;
  }

  // Mapping {productId: nom du produit} pour affichage
  Map<String, String> getProductNamesForArtisan(String artisanId) {
    final Map<String, String> names = {};
    for (var order in orders) {
      if ((order['artisanIds'] ?? []).contains(artisanId)) {
        final List<dynamic> pids = order['productIds'] ?? [];
        // Si la commande contient un seul produit, on peut récupérer le nom
        if (pids.length == 1 && order['productName'] != null) {
          names[pids.first] = order['productName'];
        }
        // Si plusieurs produits, on ne peut pas récupérer le nom ici (à moins de le stocker dans la commande)
      }
    }
    return names;
  }

  // Retourne {productName: taux} pour tous les produits de l'artisan
  Future<Map<String, double>> getProductSalesRateForArtisan(
    String artisanId,
  ) async {
    // 1. Récupérer tous les produits de l'artisan
    final productsSnapshot =
        await _firestore
            .collection('products')
            .where('artisanId', isEqualTo: artisanId)
            .get();
    final products = productsSnapshot.docs;
    if (products.isEmpty) return {};

    // 2. Compter les ventes de chaque produit
    final salesCount = getProductSalesCountForArtisan(
      artisanId,
    ); // {productId: count}
    int totalSales = salesCount.values.fold(0, (a, b) => a + b);
    if (totalSales == 0) totalSales = 1; // éviter division par zéro

    // 3. Générer le mapping {productName: taux}
    final Map<String, double> rates = {};
    for (var doc in products) {
      final pid = doc.id;
      final name = doc['name'] ?? pid;
      final count = salesCount[pid] ?? 0;
      rates[name] = (count / totalSales) * 100;
    }
    return rates;
  }
}
