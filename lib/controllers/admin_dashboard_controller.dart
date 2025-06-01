import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxInt totalArtisans = 0.obs;
  final RxInt activeArtisans = 0.obs;
  final RxInt totalCategories = 0.obs;
  final RxInt totalCommandes = 0.obs;
  final RxList<Map<String, dynamic>> categoryStats =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> artisanSignupStats =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    await Future.wait([
      loadArtisansStats(),
      loadCategoriesStats(),
      loadArtisanSignupStats(),
      loadOrdersStats(),
    ]);
  }

  Future<void> loadArtisansStats() async {
    try {
      final QuerySnapshot artisansSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'artisan')
              .get();

      totalArtisans.value = artisansSnapshot.docs.length;

      final QuerySnapshot activeArtisansSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'artisan')
              .where('isActive', isEqualTo: true)
              .get();

      activeArtisans.value = activeArtisansSnapshot.docs.length;
    } catch (e) {
      print('Erreur lors du chargement des statistiques artisans: $e');
    }
  }

  Future<void> loadCategoriesStats() async {
    try {
      final QuerySnapshot categoriesSnapshot =
          await _firestore.collection('categories').get();

      totalCategories.value = categoriesSnapshot.docs.length;

      // Récupérer les statistiques pour chaque catégorie
      List<Map<String, dynamic>> stats = [];
      for (var category in categoriesSnapshot.docs) {
        // Compter les artisans qui utilisent cette catégorie
        final QuerySnapshot artisansInCategory =
            await _firestore
                .collection('products')
                .where('categoryId', isEqualTo: category.id)
                .get();

        final Set<String> uniqueArtisans =
            artisansInCategory.docs
                .map(
                  (doc) =>
                      (doc.data() as Map<String, dynamic>)['artisanId']
                          as String,
                )
                .toSet();

        stats.add({
          'id': category.id,
          'name': (category.data() as Map<String, dynamic>)['name'] ?? '',
          'artisanCount': uniqueArtisans.length,
          'percentage':
              totalArtisans.value > 0
                  ? (uniqueArtisans.length / totalArtisans.value * 100).round()
                  : 0,
        });
      }

      categoryStats.value = stats;
    } catch (e) {
      print('Erreur lors du chargement des statistiques catégories: $e');
    }
  }

  Future<void> loadArtisanSignupStats() async {
    try {
      final QuerySnapshot artisansSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'artisan')
              .orderBy('createdAt')
              .get();

      // Grouper les inscriptions par mois
      Map<String, int> monthlySignups = {};
      for (var doc in artisansSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final Timestamp? timestamp = data['createdAt'] as Timestamp?;
        if (timestamp != null) {
          final DateTime date = timestamp.toDate();
          final String monthKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlySignups[monthKey] = (monthlySignups[monthKey] ?? 0) + 1;
        }
      }

      // Convertir en liste pour le graphique
      List<Map<String, dynamic>> signupStats = [];
      monthlySignups.forEach((key, value) {
        signupStats.add({'date': key, 'count': value});
      });

      // Trier par date
      signupStats.sort((a, b) => a['date'].compareTo(b['date']));
      artisanSignupStats.value = signupStats;
    } catch (e) {
      print('Erreur lors du chargement des statistiques d\'inscription: $e');
    }
  }

  Future<void> loadOrdersStats() async {
    try {
      final QuerySnapshot ordersSnapshot =
          await _firestore.collection('orders').get();

      totalCommandes.value = ordersSnapshot.docs.length;
    } catch (e) {
      print('Erreur lors du chargement des statistiques commandes: $e');
    }
  }

  Future<int> getActiveArtisansCount() async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('role', isEqualTo: 'artisan')
            .where('isApproved', isEqualTo: true)
            .get();
    return snapshot.docs.length;
  }

  Future<Map<String, int>> getArtisanSignupEvolution() async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('role', isEqualTo: 'artisan')
            .get();
    final Map<String, int> evolution = {};
    for (var doc in snapshot.docs) {
      final createdAt = doc['createdAt'];
      if (createdAt != null) {
        final date =
            (createdAt is Timestamp)
                ? createdAt.toDate()
                : DateTime.tryParse(createdAt.toString()) ?? DateTime.now();
        final key = DateFormat('yyyy-MM-dd HH:00').format(date);
        evolution[key] = (evolution[key] ?? 0) + 1;
      }
    }
    return evolution;
  }

  Future<List<Map<String, dynamic>>> getTopArtisansBySales() async {
    // 1. Récupérer tous les artisans
    final artisansSnapshot =
        await _firestore
            .collection('users')
            .where('role', isEqualTo: 'artisan')
            .get();
    final artisans = {
      for (var doc in artisansSnapshot.docs) doc.id: doc.data(),
    };
    // 2. Récupérer toutes les commandes
    final ordersSnapshot = await _firestore.collection('orders').get();
    final orders = ordersSnapshot.docs.map((doc) => doc.data()).toList();
    // 3. Compter les ventes par artisan
    final Map<String, int> sales = {};
    for (var order in orders) {
      final List<dynamic> artisanIds = order['artisanIds'] ?? [];
      for (var aid in artisanIds) {
        sales[aid] = (sales[aid] ?? 0) + 1;
      }
    }
    // 4. Générer la liste triée
    final List<Map<String, dynamic>> result = [];
    for (var entry in sales.entries) {
      final artisan = artisans[entry.key];
      if (artisan != null) {
        result.add({
          'artisanId': entry.key,
          'name': artisan['name'] ?? 'Artisan',
          'sales': entry.value,
          'category': artisan['category'] ?? '',
        });
      }
    }
    result.sort((a, b) => b['sales'].compareTo(a['sales']));
    return result;
  }

  Future<int> getTotalArtisansCount() async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('role', isEqualTo: 'artisan')
            .get();
    return snapshot.docs.length;
  }
}
