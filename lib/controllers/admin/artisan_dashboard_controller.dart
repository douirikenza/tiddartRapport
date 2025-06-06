import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_controller.dart';

class ArtisanDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxInt totalProducts = 0.obs;
  final RxInt activeProducts = 0.obs;
  final RxInt totalOrders = 0.obs;
  final RxInt pendingOrders = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxList<Map<String, dynamic>> recentOrders =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topProducts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    await Future.wait([
      loadProductsStats(),
      loadOrdersStats(),
      loadRecentOrders(),
      loadTopProducts(),
    ]);
  }

  Future<void> loadProductsStats() async {
    try {
      final String? artisanId = _authController.userId;
      if (artisanId == null) return;

      final QuerySnapshot productsSnapshot =
          await _firestore
              .collection('products')
              .where('artisanId', isEqualTo: artisanId)
              .get();

      totalProducts.value = productsSnapshot.docs.length;

      final QuerySnapshot activeProductsSnapshot =
          await _firestore
              .collection('products')
              .where('artisanId', isEqualTo: artisanId)
              .where('isAvailable', isEqualTo: true)
              .get();

      activeProducts.value = activeProductsSnapshot.docs.length;
    } catch (e) {
      print('Erreur lors du chargement des statistiques produits: $e');
    }
  }

  Future<void> loadOrdersStats() async {
    try {
      final String? artisanId = _authController.userId;
      if (artisanId == null) return;

      final QuerySnapshot ordersSnapshot =
          await _firestore
              .collection('orders')
              .where('artisanId', isEqualTo: artisanId)
              .get();

      totalOrders.value = ordersSnapshot.docs.length;

      final QuerySnapshot pendingOrdersSnapshot =
          await _firestore
              .collection('orders')
              .where('artisanId', isEqualTo: artisanId)
              .where('status', isEqualTo: 'pending')
              .get();

      pendingOrders.value = pendingOrdersSnapshot.docs.length;

      // Calculer le revenu total
      double revenue = 0;
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'completed') {
          revenue += (data['totalAmount'] ?? 0).toDouble();
        }
      }
      totalRevenue.value = revenue;
    } catch (e) {
      print('Erreur lors du chargement des statistiques commandes: $e');
    }
  }

  Future<void> loadRecentOrders() async {
    try {
      final String? artisanId = _authController.userId;
      if (artisanId == null) return;

      final QuerySnapshot ordersSnapshot =
          await _firestore
              .collection('orders')
              .where('artisanId', isEqualTo: artisanId)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();

      recentOrders.value =
          ordersSnapshot.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList();
    } catch (e) {
      print('Erreur lors du chargement des commandes récentes: $e');
    }
  }

  Future<void> loadTopProducts() async {
    try {
      final String? artisanId = _authController.userId;
      if (artisanId == null) return;

      final QuerySnapshot ordersSnapshot =
          await _firestore
              .collection('orders')
              .where('artisanId', isEqualTo: artisanId)
              .where('status', isEqualTo: 'completed')
              .get();

      // Compter les occurrences de chaque produit
      Map<String, int> productCount = {};
      for (var doc in ordersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>;
        for (var item in items) {
          final productId = item['productId'] as String;
          productCount[productId] = (productCount[productId] ?? 0) + 1;
        }
      }

      // Trier les produits par nombre de commandes
      final sortedProducts =
          productCount.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      // Récupérer les détails des 5 produits les plus commandés
      final topProductIds = sortedProducts.take(5).map((e) => e.key).toList();
      final productsSnapshot =
          await _firestore
              .collection('products')
              .where(FieldPath.documentId, whereIn: topProductIds)
              .get();

      topProducts.value =
          productsSnapshot.docs.map((doc) {
            final data = doc.data();
            final count = productCount[doc.id] ?? 0;
            return {'id': doc.id, ...data, 'orderCount': count};
          }).toList();
    } catch (e) {
      print('Erreur lors du chargement des produits les plus vendus: $e');
    }
  }
}
